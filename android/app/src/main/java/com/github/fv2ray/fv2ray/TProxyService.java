package com.github.fv2ray.fv2ray;

import org.json.JSONArray;
import org.json.JSONException;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import android.os.Binder;
import android.os.IBinder;
import android.os.ParcelFileDescriptor;
import android.content.Intent;
import android.net.VpnService;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.SharedPreferences;

import androidx.annotation.Nullable;

import java.io.File;
import java.io.IOException;

import libv2raymobile.Libv2raymobile;

public class TProxyService extends VpnService {
    public static native void TProxyStartService(String config_path, int fd);
    public static native void TProxyStopService();
    public static native long[] TProxyGetStats();

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
        stopTProxy();
    }

    @Override
    public void onRevoke() {
        super.onRevoke();
        stopTProxy();
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
        void onStatusUpdate(boolean isActive);
    }

    private StatusUpdateListener statusListener;
    /// Set listener for MainActivity to receive updates
    public void setStatusUpdateListener(StatusUpdateListener listener) {
        this.statusListener = listener;
    }

    public boolean getIsActive() {
        return isActive;
    }

    /// Notify MainActivity of VPN status updates
    private void notifyMainActivity() {
        if (statusListener != null) {
            statusListener.onStatusUpdate(isActive);
        }
    }



    /// vpn
    private ParcelFileDescriptor tunFd = null;
    private java.lang.Process coreProcess = null;
    private libv2raymobile.CoreManager coreManager = null;
    private boolean isActive = false;
    private SharedPreferences prefs;

    public void startTProxy() {
        startCore();

        if (prefs.getBoolean("flutter.tun", true)){
            startTun();
        }

        isActive = true;
        notifyMainActivity();
    }

    public void stopTProxy() {
        stopCore();

        if (prefs.getBoolean("flutter.tun", true)){
            stopTun();
        }

        isActive = false;
        notifyMainActivity();
    }

    private void startTun() {
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
        List<String> selectedApps = new ArrayList<>();
        try {
            JSONArray jsonArray = new JSONArray(selectedAppsString);
            for (int i = 0; i < jsonArray.length(); i++) {
                selectedApps.add(jsonArray.getString(i));
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        if (!prefs.getBoolean("flutter.tun.perAppProxy", true)) {
            session += "/Global";
        } else {
            for (String appName : selectedApps) {
                try {
                    builder.addAllowedApplication(appName);
                    disallowSelf = false;
                } catch (NameNotFoundException e) {
                }
            }
            session += "/per-App";
        }
        if (disallowSelf) {
            String selfName = getApplicationContext().getPackageName();
            try {
                builder.addDisallowedApplication(selfName);
            } catch (NameNotFoundException e) {
            }
        }
        builder.setSession(session);
        tunFd = builder.establish();
        if (tunFd == null) {
            stopSelf();
            return;
        }

        /* TProxy */
        File tproxy_file = new File(getFilesDir().getParent(), "app_flutter/fv2ray/tproxy.yaml");
        TProxyStartService(tproxy_file.getAbsolutePath(), tunFd.getFd());
    }

    private void stopTun(){
        if (tunFd != null){
            stopForeground(true);

            /* TProxy */
            TProxyStopService();

            /* VPN */
            try {
                tunFd.close();
            } catch (IOException e) {
            }
            tunFd = null;
        }
    }

    private void startCore(){
        if (coreManager != null || coreProcess != null){
            return;
        }

        /* asset location */
        String assetPath = prefs.getString("flutter.core.assetPath", "");
        if (assetPath.isEmpty()){
            File assetFolder = new File(getFilesDir().getParent(), "app_flutter/fv2ray/asset");
            assetPath = assetFolder.getAbsolutePath();
        }
        File config_file = new File(getFilesDir().getParent(), "app_flutter/fv2ray/config.gen.json");
        
        /* core */
        boolean useEmbedded = prefs.getBoolean("flutter.core.useEmbedded", true);
        if (useEmbedded){
            coreManager = new libv2raymobile.CoreManager();
            Libv2raymobile.setEnv("v2ray.location.asset", assetPath);
            Libv2raymobile.setEnv("xray.location.asset", assetPath);
            coreManager.runConfig(config_file.getAbsolutePath());
        } else {
            String corePath = prefs.getString("flutter.core.path", "");
            String[] args = {corePath, "run", "-c", config_file.getAbsolutePath()};
            ProcessBuilder processBuilder = new ProcessBuilder(args);
            Map<String, String> env = processBuilder.environment();
            env.put("v2ray.location.asset", assetPath);
            env.put("xray.location.asset", assetPath);
            try {
                coreProcess = processBuilder.start();
            } catch (Exception e) {
                e.printStackTrace();
                return;
            }
        }
    }

    private void stopCore(){
        if (coreProcess != null){
            coreProcess.destroy();
            coreProcess = null;
        }
        if (coreManager != null){
            coreManager.stop();
            coreManager = null;
        }
    }
}