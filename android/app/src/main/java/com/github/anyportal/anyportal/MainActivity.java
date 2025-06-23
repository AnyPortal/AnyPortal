package com.github.anyportal.anyportal;

import com.github.anyportal.anyportal.utils.AssetUtils;

import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.net.Uri;
import android.net.VpnService;
import android.os.Build;
import android.os.Bundle;
import android.os.FileObserver;
import android.os.IBinder;
import android.os.Looper;
import android.os.Handler;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import java.io.File;
import java.util.Arrays;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.github.anyportal.anyportal";
    private static MethodChannel methodChannel;
    private static final String TAG = "MainActivity";

    private BroadcastReceiver broadcastReceiver;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        final var messenger = flutterEngine.getDartExecutor().getBinaryMessenger();
        methodChannel = new MethodChannel(messenger, CHANNEL);
        methodChannel.setMethodCallHandler(this::onMethodCall);
    }

    @Override
    protected void onStart() {
        super.onStart();
        Intent intent = new Intent(this, MainService.class);
        bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        /* Request VPN permission */
        Intent intentVPNServicePrepare = VpnService.prepare(MainActivity.this);
        if (intentVPNServicePrepare != null) {
            Log.d(TAG, "intentVPNServicePrepare ok");
            startActivityForResult(intentVPNServicePrepare, 0);
        } else {
            Log.d(TAG, "intentVPNServicePrepare == null");
            onActivityResult(0, RESULT_OK, null);
        }
        // Copy geoip.dat and geosite.dat to the documents directory if needed
        AssetUtils.copyAssetsIfNeeded(this);

        // listen for broadcast
        registerBroadcastReceiver();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (fileObserver != null) {
            fileObserver.startWatching();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (fileObserver != null) {
            fileObserver.stopWatching();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (serviceConnection != null) {
            unbindService(serviceConnection);
            serviceConnection = null;
        }
        unregisterReceiver(broadcastReceiver);
    }

    @Override
    public void onTrimMemory(int level) {
        super.onTrimMemory(level);
        methodChannel.invokeMethod("onTrimMemory", level);
    }

    /// bind MainService
    private MainService mainService;

    private ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName className, IBinder service) {
            MainService.LocalBinder binder = (MainService.LocalBinder) service;
            mainService = binder.getService();

            // Set the status listener to receive updates
            mainService.setStatusUpdateListener(isCoreActive -> {
                Log.d(TAG, "isCoreActive: " + isCoreActive);
                // Handle VPN status update in MainActivity
                methodChannel.invokeMethod("onCoreToggled", isCoreActive);
            });
        }

        @Override
        public void onServiceDisconnected(ComponentName arg0) {
        }
    };

    ///
    private FileObserver fileObserver;

    private void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "vpn.startAll":
                mainService.tryStartAll();
                result.success(true);
                break;

            case "vpn.stopAll":
                mainService.tryStopAll();
                result.success(true);
                break;

            case "vpn.startCore":
                mainService.tryStartCore();
                result.success(true);
                break;

            case "vpn.stopCore":
                mainService.tryStopCore();
                result.success(true);
                break;

            case "vpn.startNotificationForeground":
                mainService.tryStartNotificationForeground();
                result.success(true);
                break;

            case "vpn.stopNotificationForeground":
                mainService.tryStopNotificationForeground();
                result.success(true);
                break;

            case "vpn.startTun":
                mainService.tryStartTun();
                result.success(true);
                break;

            case "vpn.stopTun":
                mainService.tryStopTun();
                result.success(true);
                break;

            case "vpn.startSystemProxy":
                result.success(mainService.tryStartSystemProxy());
                break;

            case "vpn.stopSystemProxy":
                result.success(mainService.tryStopSystemProxy());
                break;

            case "vpn.getIsSystemProxyEnabled":
                result.success(mainService.tryGetIsSystemProxyEnabled());
                break;

            case "vpn.isCoreActive":
                result.success(mainService.isCoreActive);
                break;

            case "vpn.isTunActive":
                result.success(mainService.isTunActive);
                break;

            case "vpn.isSystemProxyActive":
                result.success(mainService.isSystemProxyActive);
                break;

            case "log.core.startWatching":
                String filePath = call.argument("filePath");
                fileObserver = new FileObserver(new File(filePath)) {
                    @Override
                    public void onEvent(int event, String path) {
                        new Handler(Looper.getMainLooper()).post(new Runnable() {
                            @Override
                            public void run() {
                                if (event == FileObserver.MODIFY) {
                                    methodChannel.invokeMethod("onFileChange", null);
                                }
                            }
                        });
                    }
                };
                fileObserver.startWatching();
                break;

            case "os.abis":
                result.success(Arrays.asList(Build.SUPPORTED_ABIS));
                break;

            case "app.osArch":
                result.success(System.getProperty("os.arch"));
                break;

            case "app.targetSdkVersion":
                int targetSdk = getApplicationInfo().targetSdkVersion;
                result.success(targetSdk);
                break;

            case "os.installApk":
                String path = call.argument("path");
                installApk(path);
                result.success(null);
                break;

            default:
                result.notImplemented();
                break;
        }
    }

    private void registerBroadcastReceiver() {
        broadcastReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String action = intent.getAction();
                if (action.equals(MainTileService.ACTION_TILE_TOGGLED)) {
                    boolean isCoreActive = intent.getBooleanExtra(MainTileService.EXTRA_IS_ACTIVE, false);
                    methodChannel.invokeMethod("onTileToggled", isCoreActive);
                }
            }
        };

        registerReceiver(broadcastReceiver, new IntentFilter(MainTileService.ACTION_TILE_TOGGLED),
                RECEIVER_NOT_EXPORTED);
    }

    private void installApk(String filePath) {
        File apkFile = new File(filePath);
        if (!apkFile.exists()) return;

        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Uri apkUri = FileProvider.getUriForFile(this, getPackageName() + ".fileprovider", apkFile);
            intent.setDataAndType(apkUri, "application/vnd.android.package-archive");
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        } else {
            intent.setDataAndType(Uri.fromFile(apkFile), "application/vnd.android.package-archive");
        }

        startActivity(intent);
    }
}