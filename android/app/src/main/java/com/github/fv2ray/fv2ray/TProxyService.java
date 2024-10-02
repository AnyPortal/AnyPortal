package com.github.fv2ray.fv2ray;

import org.json.JSONArray;
import org.json.JSONException;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import android.os.ParcelFileDescriptor;
import android.content.Intent;
import android.net.VpnService;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.SharedPreferences;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import libv2raymobile.CoreManager;
import libv2raymobile.Libv2raymobile;

public class TProxyService extends VpnService {
    public static native void TProxyStartService(String config_path, int fd);
    public static native void TProxyStopService();
    public static native long[] TProxyGetStats();

    public static final String ACTION_CONNECT = "com.github.fv2ray.fv2ray.CONNECT";
    public static final String ACTION_CONNECTED = "com.github.fv2ray.fv2ray.CONNECTED";
    public static final String ACTION_DISCONNECT = "com.github.fv2ray.fv2ray.DISCONNECT";
    public static final String ACTION_DISCONNECTED = "com.github.fv2ray.fv2ray.DISCONNECTED";

    static {
        System.loadLibrary("hev-socks5-tunnel");
    }

    private ParcelFileDescriptor tunFd = null;
    private java.lang.Process coreProcess = null;
    private libv2raymobile.CoreManager coreManager = null;

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // android.os.Debug.waitForDebugger();  // this line is key
        if (intent != null && ACTION_DISCONNECT.equals(intent.getAction())) {
            stopService();
            return START_NOT_STICKY;
        }
        startService();
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stopService();
    }

    @Override
    public void onRevoke() {
        stopService();
        super.onRevoke();
    }

    public static byte[] readFileToBytes(String filePath) throws IOException {
        File file = new File(filePath);
        byte[] fileBytes = new byte[(int) file.length()];
        
        try (FileInputStream fis = new FileInputStream(file)) {
            int bytesRead = fis.read(fileBytes);
            if (bytesRead != fileBytes.length) {
                throw new IOException("Could not completely read file " + filePath);
            }
        }

        return fileBytes;
    }

    public void startService() {
        if (coreManager != null || coreProcess != null){
            return;
        }
        SharedPreferences prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);

        /* asset location */
        String assetPath = prefs.getString("flutter.core.assetPath", "");
        if (assetPath == ""){
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

        /* VPN */
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

        sendBroadcast(new Intent(ACTION_CONNECTED));
    }

    public void stopService() {
        if (coreProcess != null){
            coreProcess.destroy();
            coreProcess = null;
        }
        if (coreManager != null)
            coreManager.stop();
            coreManager = null;
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

        sendBroadcast(new Intent(ACTION_DISCONNECTED));
        System.exit(0);
    }
}