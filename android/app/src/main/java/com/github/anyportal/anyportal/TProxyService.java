package com.github.anyportal.anyportal;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.SharedPreferences;
import android.net.VpnService;
import android.os.Binder;
import android.os.IBinder;
import android.os.ParcelFileDescriptor;
import android.service.quicksettings.TileService;
import android.util.Log;

import androidx.annotation.Nullable;

import java.io.File;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.InputStreamReader;

import libv2raymobile.Libv2raymobile;

// import dev.rikka.shizuku.Shizuku;

/// despite name TProxyServiced (bind to hev-socks5-tunnel), this class should be counter part of vpn_manager.dart
public class TProxyService extends VpnService {
    public static native void TProxyStartService(String config_path, int fd);
    public static native void TProxyStopService();
    public static native long[] TProxyGetStats();
    private static final String TAG = "TProxyService";

    static {
        System.loadLibrary("hev-socks5-tunnel");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // android.os.Debug.waitForDebugger();
        return START_STICKY;
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

    @Override
    public void onRevoke() {
        super.onRevoke();
        stopAll();
    }
    
    // notify tile service
    public void updateTile() {
        ComponentName componentName = new ComponentName(this, TProxyTileService.class);
        TileService.requestListeningState(this, componentName);
    }
    
    /// bind MainActivity
    private final IBinder binder = new LocalBinder();
    public class LocalBinder extends Binder {
        public TProxyService getService() {
            return TProxyService.this;
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
        Log.d(TAG, "start target: notifyMainActivity");
        if (statusListener != null) {
            statusListener.onStatusUpdate(isCoreActive);
        } else {
            Log.w(TAG, "statusListener == null");
        }
        Log.d(TAG, "reached target: notifyMainActivity");
    }



    /// vpn
    private ParcelFileDescriptor tunFd = null;
    private java.lang.Process coreProcess = null;
    private libv2raymobile.CoreManager coreManager = null;
    public boolean isCoreActive = false;
    public boolean isTunActive = false;
    public boolean isSystemProxyActive = false;
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

    public void tryStartTun() {
        try {
            startTun();
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
        Log.d(TAG, "start target: startAll");

        startCore();
        isCoreActive = true;

        if (prefs.getBoolean("flutter.tun", true)){
            startTun();
            isTunActive = true;
        }

        notifyMainActivity();
        updateTile();

        Log.d(TAG, "reached target: startAll");
    }

    private void stopAll() {
        Log.d(TAG, "start target: stopAll");

        stopCore();
        isCoreActive = false;

        if (prefs.getBoolean("flutter.tun", true)){
            stopTun();
            isTunActive = false;
        }

        notifyMainActivity();
        updateTile();

        Log.d(TAG, "reached target: stopAll");
    }

    private void startTun() {
        Log.d(TAG, "start target: startTun");

        if (tunFd != null)
          return;

        String session = "";
        VpnService.Builder builder = new VpnService.Builder();
        builder.setBlocking(false);
        builder.setMtu(8500);
        if (prefs.getBoolean("flutter.tun.ipv4", true)) {
            String addr = "198.18.0.1";
            int prefix = 32;
            String dns = prefs.getString("flutter.tun.dns.ipv4", "1.1.1.1");
            builder.addAddress(addr, prefix);
            builder.addRoute("0.0.0.0", 0);
            if (!dns.isEmpty())
              builder.addDnsServer(dns);
            session += "IPv4";
        }
        if (prefs.getBoolean("flutter.tun.ipv6", true)) {
            String addr = "fc00::1";
            int prefix = 128;
            String dns = prefs.getString("flutter.tun.dns.ipv6", "2606:4700:4700::1111");
            builder.addAddress(addr, prefix);
            builder.addRoute("::", 0);
            if (!dns.isEmpty())
              builder.addDnsServer(dns);
            if (!session.isEmpty())
              session += " + ";
            session += "IPv6";
        }
        boolean disallowSelf = true;
        String selectedAppsString = prefs.getString("flutter.tun.selectedApps", "[]");
        List<String> selectedApps = getStringListFromJsonString(selectedAppsString);
        if (!prefs.getBoolean("flutter.tun.perAppProxy", true)) {
            session += "/Global";
        } else {
            for (String appName : selectedApps) {
                try {
                    builder.addAllowedApplication(appName);
                    disallowSelf = false;
                } catch (NameNotFoundException e) {
                    Log.w(TAG, e);
                }
            }
            session += "/per-App";
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
            stopSelf();
            return;
        }

        /* TProxy */
        File tproxy_file = new File(getFilesDir(), "conf/tun.hev_socks5_tunnel.gen.yaml");
        TProxyStartService(tproxy_file.getAbsolutePath(), tunFd.getFd());

        Log.d(TAG, "reached target: startTun");
    }

    private List<String> getStringListFromJsonString(String str){
        List<String> res = new ArrayList<>();
        try {
            JSONArray jsonArray = new JSONArray(str);
            for (int i = 0; i < jsonArray.length(); i++) {
                res.add(jsonArray.getString(i));
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return res;
    }

    private Map<String, String> getStringStringMapFromJsonString(String str){
        Map<String, String> res = new HashMap<String, String>();
        try {
            JSONObject jsonObject = new JSONObject(str);
            Iterator<String> keys = jsonObject.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                String value = jsonObject.getString(key); // Get the value as a string
                res.put(key, value);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return res;
    }

    private void stopTun(){
        Log.d(TAG, "start target: stopTun");

        if (tunFd != null){
            // stopForeground(true);

            /* TProxy */
            TProxyStopService();

            /* VPN */
            try {
                tunFd.close();
            } catch (IOException e) {
            }
            tunFd = null;
        }
        
        Log.d(TAG, "reached target: stopTun");
    }

    private void startCore(){
        Log.d(TAG, "start target: stopCore");

        if (coreManager != null || coreProcess != null){
            return;
        }

        /* asset location */
        File libAssetFolder = new File(getFilesDir().getParent(), "files/asset");
        String libAssetPath = libAssetFolder.getAbsolutePath();
        File config_file = new File(getFilesDir().getParent(), "files/conf/core.gen.json");
        
        /* core */
        boolean useEmbedded = prefs.getBoolean("flutter.cache.core.useEmbedded", true);
        if (useEmbedded){
            coreManager = new libv2raymobile.CoreManager();
            Libv2raymobile.setEnv("v2ray.location.asset", libAssetPath);
            Libv2raymobile.setEnv("xray.location.asset", libAssetPath);
            coreManager.runConfig(config_file.getAbsolutePath());
        } else {
            String corePath = prefs.getString("flutter.cache.core.path", "");
            new File(corePath).setExecutable(true);
            List<String> coreArgs = getStringListFromJsonString(prefs.getString("flutter.cache.core.args", "[]"));
            String coreWorkingDir = prefs.getString("flutter.cache.core.workingDir", "");
            Map<String, String> coreEnvs = getStringStringMapFromJsonString(prefs.getString("flutter.cache.core.envs", "{}"));
            
            coreArgs.add(0, corePath);
            ProcessBuilder pb = new ProcessBuilder(coreArgs);
            /// external storage can not be used as working dir !!
            pb.directory(new File(coreWorkingDir));
            Map<String, String> env = pb.environment();
            env.putAll(coreEnvs);

            try {
                coreProcess = pb.start();
            } catch (Exception e) {
                e.printStackTrace();
                return;
            }
        }

        Log.d(TAG, "reached target: startCore");
    }

    private void stopCore(){
        Log.d(TAG, "start target: stopCore");

        if (coreProcess != null){
            coreProcess.destroy();
            coreProcess = null;
        }
        if (coreManager != null){
            coreManager.stop();
            coreManager = null;
        }

        Log.d(TAG, "reached target: stopCore");
    }

    private int startSystemProxy(){
        Log.d(TAG, "start target: startSystemProxy");

        // if (!Shizuku.isPreV23() && Shizuku.checkSelfPermission() != PackageManager.PERMISSION_GRANTED) {
        //     Shizuku.requestPermission(0);
        // }

        String serverAddress = prefs.getString("flutter.app.server.address", "127.0.0.1");
        long httpPort = prefs.getLong("flutter.app.http.port", 15492);

        String cmd = String.format("settings put global http_proxy %s:%d", serverAddress, httpPort);

        // int process = Shizuku.newProcess(new String[]{"sh", "-c", cmd}, null, null).waitFor();

        ProcessBuilder pb = new ProcessBuilder(new String[]{"su", "-c", cmd});
        int exitCode = -1;
        try {
            exitCode = pb.start().waitFor();
        } catch (Exception e) {
            e.printStackTrace();
        }

        Log.d(TAG, "reached target: startSystemProxy");
        return exitCode;
    }

    private int stopSystemProxy(){
        Log.d(TAG, "start target: stopSystemProxy");

        String cmd = "settings put global http_proxy :0";
        // int process = Shizuku.newProcess(new String[]{"sh", "-c", cmd}, null, null).waitFor();
        ProcessBuilder pb = new ProcessBuilder(new String[]{"su", "-c", cmd});
        int exitCode = -1;
        try {
            exitCode = pb.start().waitFor();
        } catch (Exception e) {
            e.printStackTrace();
        }

        Log.d(TAG, "reached target: stopSystemProxy");
        return exitCode;
    }

    private boolean getIsSystemProxyEnabled(){
        Log.d(TAG, "start target: getIsSystemProxyEnabled");

        String cmd = "settings get global http_proxy";
        // int process = Shizuku.newProcess(new String[]{"sh", "-c", cmd}, null, null).waitFor();
        ProcessBuilder pb = new ProcessBuilder(new String[]{"su", "-c", cmd});
        int exitCode = -1;
        try {
            java.lang.Process process = pb.start();
            // Read the command's output
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            StringBuilder output = new StringBuilder();

            while ((line = reader.readLine()) != null) {
                output.append(line.trim());  // trim() to remove any surrounding whitespace
            }

            reader.close();

            // Check if the output is ":0"
            return output.toString().equals(":0");
        } catch (Exception e) {
            e.printStackTrace();
        }

        Log.d(TAG, "reached target: getIsSystemProxyEnabled");
        return false;
    }
}