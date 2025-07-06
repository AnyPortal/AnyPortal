package com.github.anyportal.anyportal;

import com.github.anyportal.anyportal.utils.JsonUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.net.VpnService;
import android.os.Binder;
import android.os.Build;
import android.os.IBinder;
import android.os.ParcelFileDescriptor;
import android.service.quicksettings.TileService;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import java.io.File;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;

import com.github.anyportal.anyportal.R;

public class TProxyService extends VpnService {
    public static final String ACTION_NULL = "com.github.anyportal.anyportal.ACTION_NULL";
    private static final String TAG = "TProxyService";
    private static final String CHANNEL_ID = "vpn_channel_id";
    private static final int NOTIFICATION_ID = 1;
    public static volatile boolean isRunning = false;

    private final IBinder binder = new LocalBinder();

    public class LocalBinder extends Binder {
        public TProxyService getService() {
            return TProxyService.this;
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        if (VpnService.SERVICE_INTERFACE.equals(intent.getAction())) {
            return super.onBind(intent);
        }
        return binder;
    }

    static {
        System.loadLibrary("hev-socks5-tunnel");
    }

    public static native void TProxyStartService(String config_path, int fd);

    public static native void TProxyStopService();

    public static native long[] TProxyGetStats();

    private ParcelFileDescriptor tunFd = null;
    private SharedPreferences prefs;

    @Override
    public void onCreate() {
        super.onCreate();
        isRunning = true;
        prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null && ACTION_NULL.equals(intent.getAction())) {
            /// started by app
        } else {
            /// started by system vpn toggle
            tryStartAll();
        }
        return START_STICKY;
    }

    @Override
    public void onRevoke() {
        tryStopAll();
        super.onRevoke();
    }

    @Override
    public void onDestroy() {
        tryStopAll();
        super.onDestroy();
    }

    private void createNotificationChannel() {
        Log.d(TAG, "starting: createNotificationChannel");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "VPN Service Channel",
                    NotificationManager.IMPORTANCE_DEFAULT);
            channel.setDescription("Notification channel for VPN service");

            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
            Log.d(TAG, "NotificationChannel created");
        }
    }

    private Notification createNotification() {
        // Intent to launch main activity
        Intent notificationIntent = new Intent(getApplicationContext(), MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(
                this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE);

        // Build the notification
        return new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("AnyPortal")
                // .setContentText("The VPN service is running")
                .setSmallIcon(R.drawable.ic_launcher_monochrome)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
                .build();
    }

    // notify tile service
    public void updateTile() {
        ComponentName componentName = new ComponentName(this, MainTileService.class);
        TileService.requestListeningState(this, componentName);
    }

    /// Interface for MainActivity to receive status change
    public static interface StatusChangeListener {
        void onAllStatusChange(boolean isCoreActive);
        void onCoreStatusChange(boolean isCoreActive);
        void onTunStatusChange(boolean isTunActive);
        void onSystemProxyStatusChange(boolean isSystemProxyActive);
    }

    private StatusChangeListener statusChangeListener;

    public void setStatusChangeListener(StatusChangeListener listener) {
        this.statusChangeListener = listener;
    }

    private void notifyMainActivityAllStatusChange() {
        if (statusChangeListener != null) {
            statusChangeListener.onAllStatusChange(isCoreActive);
        }
    }

    private void notifyMainActivityCoreStatusChange() {
        if (statusChangeListener != null) {
            statusChangeListener.onCoreStatusChange(isCoreActive);
        }
    }

    private void notifyMainActivityTunStatusChange() {
        if (statusChangeListener != null) {
            statusChangeListener.onTunStatusChange(isTunActive);
        }
    }

    private void notifyMainActivitySystemProxyStatusChange() {
        if (statusChangeListener != null) {
            statusChangeListener.onSystemProxyStatusChange(isSystemProxyActive);
        }
    }

    /// vpn
    private java.lang.Process coreProcess = null;
    private java.lang.Process tunSingBoxCoreSuShell = null;
    private int tunSingBoxCorePid = -1;
    public boolean isCoreActive = false;
    public boolean isTunActive = false;
    public boolean isSystemProxyActive = false;
    /// for binding control
    public boolean shouldCoreActive = false;
    public boolean shouldTunActive = false;

    public void tryStartAll() {
        try {
            startAll();
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }
    }

    public void tryStopAll() {
        try {
            stopAll();
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }
    }

    public void tryStartNotificationForeground() {
        try {
            startNotificationForeground();
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }
    }

    public void tryStopNotificationForeground() {
        try {
            stopNotificationForeground();
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }
    }

    public void tryStartTun() {
        try {
            startTun();
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }
    }

    public void tryStopCore() {
        try {
            stopCore();
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }
    }

    public void tryStartCore() {
        try {
            startCore();
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }
    }

    public void tryStopTun() {
        try {
            stopTun();
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }
    }

    public int tryStartSystemProxy() {
        try {
            return startSystemProxy();
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }

    public int tryStopSystemProxy() {
        try {
            return stopSystemProxy();
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }

    public boolean tryGetIsSystemProxyEnabled() {
        try {
            return getIsSystemProxyEnabled();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private void startAll() {
        Log.d(TAG, "starting: startAll");

        if (prefs.getBoolean("flutter.app.notification.foreground", true)) {
            startNotificationForeground();
        }

        startCore();

        if (prefs.getBoolean("flutter.tun", true)) {
            startTun();
        }

        if (prefs.getBoolean("flutter.systemProxy", true)) {
            startSystemProxy();
        }

        notifyMainActivityAllStatusChange();
        updateTile();

        Log.d(TAG, "finished: startAll");
    }

    private void stopAll() {
        Log.d(TAG, "starting: stopAll");
        stopCore();

        if (prefs.getBoolean("flutter.tun", true)) {
            stopTun();
        }

        if (prefs.getBoolean("flutter.systemProxy", true)) {
            stopSystemProxy();
        }

        notifyMainActivityAllStatusChange();
        updateTile();

        stopNotificationForeground();

        Log.d(TAG, "finished: stopAll");
    }

    private void startNotificationForeground() {
        createNotificationChannel();
        Notification notification = createNotification();
        notification.flags |= Notification.FLAG_NO_CLEAR;
        startForeground(NOTIFICATION_ID, notification);
    }

    private void stopNotificationForeground() {
        stopForeground(STOP_FOREGROUND_REMOVE);
    }

    private final ServiceConnection libV2RayConnection = new ServiceConnection() {
        public void onServiceConnected(ComponentName name, IBinder service) {
            Log.d(TAG, "LibV2RayService connected");
        }

        public void onServiceDisconnected(ComponentName name) {
            Log.d(TAG, "LibV2RayService disconnected");
            if (shouldCoreActive) {
                Log.w(TAG, "LibV2RayService disconnected, rebinding...");
                bindLibV2RayService();
            }
        }
    };;

    private void bindLibV2RayService() {
        Intent intent = new Intent(this, LibV2RayService.class);
        bindService(intent, libV2RayConnection, Context.BIND_AUTO_CREATE);
    }

    private void startTunExec() {
        Log.d(TAG, "starting: startTunExec");
        String corePath = prefs.getString("flutter.cache.tun.singBox.core.path", "");
        new File(corePath).setExecutable(true);
        List<String> coreArgs = JsonUtils.getStringListFromJsonString(
                prefs.getString("flutter.cache.tun.singBox.core.args", "[]"));
        String coreWorkingDir = prefs.getString("flutter.cache.tun.singBox.core.workingDir", "");
        Map<String, String> coreEnvs = JsonUtils.getStringStringMapFromJsonString(
                prefs.getString("flutter.tun.singBox.cache.core.envs", "{}"));

        coreArgs.add(0, corePath);
        ProcessBuilder pb = new ProcessBuilder("su");
        /// external storage can not be used as working dir !!
        if (!coreWorkingDir.isEmpty()) {
            pb.directory(new File(coreWorkingDir));
        }
        Map<String, String> env = pb.environment();
        env.putAll(coreEnvs);

        try {
            tunSingBoxCoreSuShell = pb.start();
            OutputStream os = tunSingBoxCoreSuShell.getOutputStream();
            String cmd = String.join(" ", coreArgs);
            os.write(("sh -c '" + cmd + " & echo $!'\n").getBytes());
            os.flush();
            BufferedReader reader = new BufferedReader(new InputStreamReader(tunSingBoxCoreSuShell.getInputStream()));
            String line;
            while ((line = reader.readLine()) != null) {
                try {
                    tunSingBoxCorePid = Integer.parseInt(line.trim());
                    Log.d(TAG, String.format("tunSingBoxCorePid: %d", tunSingBoxCorePid));
                    break; // Got the PID
                } catch (NumberFormatException e) {
                    Log.e(TAG, String.format("NumberFormatException: %s", line));
                    e.printStackTrace();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }
        Log.d(TAG, "finished: startTunExec");
    }

    private void stopTunExec() {
        if (tunSingBoxCoreSuShell != null) {
            if (tunSingBoxCorePid != -1) {
                try {
                    new ProcessBuilder("su", "-c", "kill -9 " + tunSingBoxCorePid).start();
                } catch (Exception e) {
                    e.printStackTrace();
                    return;
                }
                tunSingBoxCorePid = -1;
            }
            tunSingBoxCoreSuShell.destroy();
            tunSingBoxCoreSuShell = null;
        }
    }

    private void startTunEmbedded() {
        if (tunFd != null) {
            return;
        }

        Context ctx = getApplicationContext();
        Intent intentVPNServicePrepare = VpnService.prepare(ctx);
        if (intentVPNServicePrepare != null) {
            Log.d(TAG, "intentVPNServicePrepare ok");
            intentVPNServicePrepare.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            ctx.startActivity(intentVPNServicePrepare);
        } else {
            Log.d(TAG, "intentVPNServicePrepare == null");
        }

        String session = "";
        VpnService.Builder builder = new VpnService.Builder();
        builder.setBlocking(false);
        builder.setMtu(8500);
        if (prefs.getBoolean("flutter.tun.ipv4", true)) {
            String addr = "172.19.0.1";
            int prefix = 30;
            String dns = prefs.getString("flutter.tun.dns.ipv4", "1.1.1.1");
            builder.addAddress(addr, prefix);
            builder.addRoute("0.0.0.0", 0);
            if (!dns.isEmpty()) {
                builder.addDnsServer(dns);
            }
            session += "IPv4";
        }
        if (prefs.getBoolean("flutter.tun.ipv6", true)) {
            String addr = "fdfe:dcba:9876::1";
            int prefix = 126;
            String dns = prefs.getString("flutter.tun.dns.ipv6", "2606:4700:4700::1111");
            builder.addAddress(addr, prefix);
            builder.addRoute("::", 0);
            if (!dns.isEmpty()) {
                builder.addDnsServer(dns);
            }
            if (!session.isEmpty()) {
                session += " + ";
            }
            session += "IPv6";
        }
        boolean disallowSelf = true;

        if (!prefs.getBoolean("flutter.tun.perAppProxy", true)) {
            session += "/Global";
        } else {
            session += "/per-App";
            if (prefs.getBoolean("flutter.android.tun.perAppProxy.allowed", true)) {
                String selectedAppsString = prefs.getString("flutter.android.tun.allowedApplications", "[]");
                List<String> selectedApps = JsonUtils.getStringListFromJsonString(selectedAppsString);
                for (String appName : selectedApps) {
                    try {
                        builder.addAllowedApplication(appName);
                    } catch (NameNotFoundException e) {
                        Log.w(TAG, e);
                    }
                }
                if (!selectedAppsString.equals("[]")) {
                    disallowSelf = false;
                }
            } else {
                String selectedAppsString = prefs.getString("flutter.android.tun.disAllowedApplications", "[]");
                List<String> selectedApps = JsonUtils.getStringListFromJsonString(selectedAppsString);
                for (String appName : selectedApps) {
                    try {
                        builder.addDisallowedApplication(appName);
                    } catch (NameNotFoundException e) {
                        Log.w(TAG, e);
                    }
                }
            }
        }
        if (disallowSelf) {
            String selfName = getApplicationContext().getPackageName();
            try {
                builder.addDisallowedApplication(selfName);
            } catch (NameNotFoundException e) {
                Log.w(TAG, e);
            }
        }
        builder.setSession(session);
        tunFd = builder.establish();
        if (tunFd == null) {
            Log.w(TAG, "tunFd == null");
            stopSelf();
            return;
        }

        File tproxy_file = new File(getFilesDir(), "conf/tun.hev_socks5_tunnel.gen.yaml");
        TProxyStartService(tproxy_file.getAbsolutePath(), tunFd.getFd());
    }

    private void stopTunEmbedded() {
        if (tunFd != null) {
            TProxyStopService();

            try {
                tunFd.close();
            } catch (IOException e) {
            }
            tunFd = null;
        }
    }

    private void startTun() {
        Log.d(TAG, "starting: startTun");
        shouldTunActive = true;
        boolean useEmbedded = prefs.getBoolean("flutter.tun.useEmbedded", true);
        if (useEmbedded) {
            startTunEmbedded();
        } else {
            startTunExec();
        }
        isTunActive = true;
        notifyMainActivityTunStatusChange();
        Log.d(TAG, "finished: startTun");
    }

    private void stopTun() {
        Log.d(TAG, "starting: stopTun");
        shouldTunActive = false;

        stopTunEmbedded();
        stopTunExec();

        isTunActive = false;
        notifyMainActivityTunStatusChange();
        Log.d(TAG, "finished: stopTun");
    }

    private void startCore() {
        Log.d(TAG, "starting: startCore");
        shouldCoreActive = true;

        boolean useEmbedded = prefs.getBoolean("flutter.cache.core.useEmbedded", true);
        if (useEmbedded) {
            Intent intent = new Intent(getApplicationContext(), LibV2RayService.class);
            startService(intent);
            bindLibV2RayService();
        } else {
            if (coreProcess != null) {
                return;
            }

            String corePath = prefs.getString("flutter.cache.core.path", "");
            new File(corePath).setExecutable(true);
            List<String> coreArgs = JsonUtils
                    .getStringListFromJsonString(prefs.getString("flutter.cache.core.args", "[]"));
            String coreWorkingDir = prefs.getString("flutter.cache.core.workingDir", "");
            Map<String, String> coreEnvs = JsonUtils.getStringStringMapFromJsonString(
                    prefs.getString("flutter.cache.core.envs", "{}"));

            coreArgs.add(0, corePath);
            ProcessBuilder pb = new ProcessBuilder(coreArgs);
            /// external storage can not be used as working dir !!
            if (!coreWorkingDir.isEmpty()) {
                pb.directory(new File(coreWorkingDir));
            }
            Map<String, String> env = pb.environment();
            env.putAll(coreEnvs);

            try {
                coreProcess = pb.start();
            } catch (Exception e) {
                e.printStackTrace();
                return;
            }
        }

        isCoreActive = true;
        notifyMainActivityCoreStatusChange();
        Log.d(TAG, "finished: startCore");
    }

    private void stopCore() {
        Log.d(TAG, "starting: stopCore");
        shouldCoreActive = false;

        if (coreProcess != null) {
            coreProcess.destroy();
            coreProcess = null;
        }

        try {
            unbindService(libV2RayConnection);
        } catch (IllegalArgumentException e) {
            // Already unbound or was never bound — safe to ignore
            Log.w(TAG, "LibV2RayService was not bound: " + e.getMessage());
        }
        // /// just stopService does not work unless run LibV2RayService.stopCore first
        // Intent stopIntent = new Intent(getApplicationContext(),
        // LibV2RayService.class);
        // stopIntent.setAction(LibV2RayService.ACTION_STOP_LIBV2RAYSERVICE);
        // startService(stopIntent);
        // just stopService is enough
        stopService(new Intent(getApplicationContext(), LibV2RayService.class));

        isCoreActive = false;
        notifyMainActivityCoreStatusChange();
        Log.d(TAG, "finished: stopCore");
    }

    private int startSystemProxy() {
        Log.d(TAG, "starting: startSystemProxy");

        // if (!Shizuku.isPreV23() && Shizuku.checkSelfPermission() !=
        // PackageManager.PERMISSION_GRANTED) {
        // Shizuku.requestPermission(0);
        // }

        String serverAddress = prefs.getString("flutter.app.server.address", "127.0.0.1");
        long httpPort = prefs.getLong("flutter.app.http.port", 15492);

        String cmd = String.format("settings put global http_proxy %s:%d", serverAddress, httpPort);

        // int process = Shizuku.newProcess(new String[]{"sh", "-c", cmd}, null,
        // null).waitFor();

        ProcessBuilder pb = new ProcessBuilder(new String[] { "su", "-c", cmd });
        int exitCode = -1;
        try {
            exitCode = pb.start().waitFor();
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (exitCode == 0) {
            isSystemProxyActive = true;
        }

        notifyMainActivitySystemProxyStatusChange();
        Log.d(TAG, "finished: startSystemProxy");
        return exitCode;
    }

    private int stopSystemProxy() {
        Log.d(TAG, "starting: stopSystemProxy");

        String cmd = "settings put global http_proxy :0";
        // int process = Shizuku.newProcess(new String[]{"sh", "-c", cmd}, null,
        // null).waitFor();
        ProcessBuilder pb = new ProcessBuilder(new String[] { "su", "-c", cmd });
        int exitCode = -1;
        try {
            exitCode = pb.start().waitFor();
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (exitCode == 0) {
            isSystemProxyActive = false;
        }

        notifyMainActivitySystemProxyStatusChange();
        Log.d(TAG, "finished: stopSystemProxy");
        return exitCode;
    }

    private boolean getIsSystemProxyEnabled() {
        Log.d(TAG, "starting: getIsSystemProxyEnabled");

        String cmd = "settings get global http_proxy";
        // int process = Shizuku.newProcess(new String[]{"sh", "-c", cmd}, null,
        // null).waitFor();
        ProcessBuilder pb = new ProcessBuilder(new String[] { "su", "-c", cmd });
        int exitCode = -1;
        try {
            java.lang.Process process = pb.start();
            // Read the command's output
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            StringBuilder output = new StringBuilder();

            while ((line = reader.readLine()) != null) {
                output.append(line.trim()); // trim() to remove any surrounding whitespace
            }

            reader.close();

            // Check if the output is ":0"
            boolean res = output.toString().equals(":0");
            Log.d(TAG, "finished: getIsSystemProxyEnabled");
            return res;
        } catch (Exception e) {
            e.printStackTrace();
        }

        Log.d(TAG, "finished: getIsSystemProxyEnabled");
        return false;
    }
}
