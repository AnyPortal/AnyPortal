package com.github.anyportal.anyportal;

import com.github.anyportal.anyportal.utils.JsonUtils;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.SharedPreferences;
import android.net.VpnService;
import android.os.Binder;
import android.os.IBinder;
import android.os.ParcelFileDescriptor;
import android.util.Log;

import androidx.annotation.Nullable;

import java.io.File;
import java.io.IOException;


public class TProxyService extends VpnService{
    public static final String ACTION_STOP_T_PROXY_SERVICE_TUN = "com.github.anyportal.anyportal.ACTION_STOP_T_PROXY_SERVICE_TUN";
    private static final String TAG = "TProxyService";
    
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
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null && ACTION_STOP_T_PROXY_SERVICE_TUN.equals(intent.getAction())) {
            stopTun();
            return START_NOT_STICKY;
        }

        startTun();
        return START_STICKY;
    }

    @Override
    public void onRevoke() {
        super.onRevoke();
        stopTun();
    }

    @Override
    public void onDestroy() {
        stopTun();
        super.onDestroy();
    }

    private void startTun() {
        prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);

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
            String addr = "198.18.0.1";
            int prefix = 32;
            String dns = prefs.getString("flutter.tun.dns.ipv4", "1.1.1.1");
            builder.addAddress(addr, prefix);
            builder.addRoute("0.0.0.0", 0);
            if (!dns.isEmpty()) {
                builder.addDnsServer(dns);
            }
            session += "IPv4";
        }
        if (prefs.getBoolean("flutter.tun.ipv6", true)) {
            String addr = "fc00::1";
            int prefix = 128;
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
                if (selectedAppsString != "[]"){
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

    private void stopTun() {
        if (tunFd != null) {
            TProxyStopService();

            try {
                tunFd.close();
            } catch (IOException e) {
            }
            tunFd = null;
        }
    }
}
