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
import android.os.Binder;
import android.os.Build;
import android.os.IBinder;
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

// import dev.rikka.shizuku.Shizuku;


public class MainService extends Service {
    private static final String TAG = "MainService";
    private static final String CHANNEL_ID = "vpn_channel_id";
    private static final int NOTIFICATION_ID = 1;


    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // android.os.Debug.waitForDebugger();
        return START_STICKY;
    }

    private void createNotificationChannel() {
        Log.d(TAG, "starting: createNotificationChannel");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Log.d(TAG, "NotificationChannel");
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "VPN Service Channel",
                    NotificationManager.IMPORTANCE_DEFAULT);
            channel.setDescription("Notification channel for VPN service");

            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
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

    @Override
    public void onCreate() {
        super.onCreate();
        prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stopAll();
    }

    // notify tile service
    public void updateTile() {
        ComponentName componentName = new ComponentName(this, MainTileService.class);
        TileService.requestListeningState(this, componentName);
    }

    /// bind MainActivity
    private final IBinder binder = new LocalBinder();

    public class LocalBinder extends Binder {
        public MainService getService() {
            return MainService.this;
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }


    /// Interface for MainActivity to receive status updates
    public interface StatusUpdateListener {
        void onStatusUpdate(boolean isCoreActive);
    }

    private StatusUpdateListener statusListener;

    /// Set listener for MainActivity to receive updates
    public void setStatusUpdateListener(StatusUpdateListener listener) {
        this.statusListener = listener;
    }

    /// Notify MainActivity of VPN status updates
    private void notifyMainActivity() {
        Log.d(TAG, "starting: notifyMainActivity");
        if (statusListener != null) {
            statusListener.onStatusUpdate(isCoreActive);
        } else {
            Log.w(TAG, "statusListener == null");
        }
        Log.d(TAG, "finished: notifyMainActivity");
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

    private SharedPreferences prefs;

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

        notifyMainActivity();
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

        notifyMainActivity();
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

    private ServiceConnection libV2rayConnection;
    private ServiceConnection tProxyConnection;

    private void bindLibV2rayService() {
        libV2rayConnection = new ServiceConnection() {
            public void onServiceConnected(ComponentName name, IBinder service) {
                Log.d(TAG, "LibV2rayService connected");
            }

            public void onServiceDisconnected(ComponentName name) {
                Log.d(TAG, "LibV2rayService disconnected");
                if (shouldTunActive) {
                    Log.w(TAG, "LibV2rayService disconnected, rebinding...");
                    bindLibV2rayService();
                }                
            }
        };

        Intent intent = new Intent(this, LibV2rayService.class);
        bindService(intent, libV2rayConnection, Context.BIND_AUTO_CREATE);
    }

    private void bindTProxyService() {
        tProxyConnection = new ServiceConnection() {
            public void onServiceConnected(ComponentName name, IBinder service) {
                Log.d(TAG, "TProxyService connected");
            }

            public void onServiceDisconnected(ComponentName name) {
                Log.d(TAG, "TProxyService disconnected");
                if (shouldCoreActive) {
                    Log.w(TAG, "TProxyService disconnected, rebinding...");
                    bindLibV2rayService();
                }                
            }
        };

        Intent intent = new Intent(this, TProxyService.class);
        bindService(intent, tProxyConnection, Context.BIND_AUTO_CREATE);
    }

    private void startTunEmbedded() {
        Log.d(TAG, "starting: startTunEmbedded");
        startService(new Intent(getApplicationContext(), TProxyService.class));
        bindTProxyService();
        Log.d(TAG, "finished: startTunEmbedded");
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
        Log.d(TAG, "finished: startTun");
    }


    private void stopTun() {
        Log.d(TAG, "starting: stopTun");
        shouldTunActive = false;

        /// just stopService does not work unless run TProxyService.stopTun first
        Intent stopIntent = new Intent(getApplicationContext(), TProxyService.class);
        stopIntent.setAction(TProxyService.ACTION_STOP_T_PROXY_SERVICE_TUN);
        startService(stopIntent);
        try {
            unbindService(tProxyConnection);
        } catch (IllegalArgumentException e) {
            // Already unbound or was never bound — safe to ignore
            Log.w(TAG, "TProxyService was not bound: " + e.getMessage());
        }
        stopService(new Intent(getApplicationContext(), TProxyService.class));

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

        isTunActive = false;
        Log.d(TAG, "finished: stopTun");
    }

    private void startCore() {
        Log.d(TAG, "starting: startCore");
        shouldCoreActive = true;

        boolean useEmbedded = prefs.getBoolean("flutter.cache.core.useEmbedded", true);
        if (useEmbedded) {
            Intent intent = new Intent(getApplicationContext(), LibV2rayService.class);
            startService(intent);
            bindLibV2rayService();
        } else {
            if (coreProcess != null) {
                return;
            }
            String corePath = prefs.getString("flutter.cache.core.path", "");
            new File(corePath).setExecutable(true);
            List<String> coreArgs = JsonUtils.getStringListFromJsonString(prefs.getString("flutter.cache.core.args", "[]"));
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
            unbindService(libV2rayConnection);
        } catch (IllegalArgumentException e) {
            // Already unbound or was never bound — safe to ignore
            Log.w(TAG, "LibV2rayService was not bound: " + e.getMessage());
        }
        stopService(new Intent(getApplicationContext(), LibV2rayService.class));

        isCoreActive = false;
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
        
        if (exitCode == 0){
            isSystemProxyActive = true;
        }

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

        if (exitCode == 0){
            isSystemProxyActive = false;
        }

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
            return output.toString().equals(":0");
        } catch (Exception e) {
            e.printStackTrace();
        }

        Log.d(TAG, "finished: getIsSystemProxyEnabled");
        return false;
    }
}