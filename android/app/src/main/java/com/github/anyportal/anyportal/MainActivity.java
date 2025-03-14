package com.github.anyportal.anyportal;

import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.net.VpnService;
import android.os.Bundle;
import android.os.FileObserver;
import android.os.IBinder;
import android.os.Looper;
import android.os.Handler;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import java.io.File;

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
        Intent intent = new Intent(this, TProxyService.class);
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

    /// bind TProxyService
    private TProxyService tProxyService;

    private ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName className, IBinder service) {
            TProxyService.LocalBinder binder = (TProxyService.LocalBinder) service;
            tProxyService = binder.getService();

            // Set the status listener to receive updates
            tProxyService.setStatusUpdateListener(isCoreActive -> {
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
                tProxyService.tryStartAll();
                result.success(true);
                break;

            case "vpn.stopAll":
                tProxyService.tryStopAll();
                result.success(true);
                break;

            case "vpn.startCore":
                tProxyService.tryStartCore();
                result.success(true);
                break;

            case "vpn.stopCore":
                tProxyService.tryStopCore();
                result.success(true);
                break;

            case "vpn.startNotificationForeground":
                tProxyService.tryStartNotificationForeground();
                result.success(true);
                break;

            case "vpn.stopNotificationForeground":
                tProxyService.tryStopNotificationForeground();
                result.success(true);
                break;

            case "vpn.startTun":
                tProxyService.tryStartTun();
                result.success(true);
                break;

            case "vpn.stopTun":
                tProxyService.tryStopTun();
                result.success(true);
                break;

            case "vpn.startSystemProxy":
                result.success(tProxyService.tryStartSystemProxy());
                break;

            case "vpn.stopSystemProxy":
                result.success(tProxyService.tryStopSystemProxy());
                break;

            case "vpn.getIsSystemProxyEnabled":
                result.success(tProxyService.tryGetIsSystemProxyEnabled());
                break;

            case "vpn.isCoreActive":
                result.success(tProxyService.isCoreActive);
                break;

            case "vpn.isTunActive":
                result.success(tProxyService.isTunActive);
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
                if (action.equals(TProxyTileService.ACTION_TILE_TOGGLED)) {
                    boolean isCoreActive = intent.getBooleanExtra(TProxyTileService.EXTRA_IS_ACTIVE, false);
                    methodChannel.invokeMethod("onTileToggled", isCoreActive);
                }
            }
        };

        registerReceiver(broadcastReceiver, new IntentFilter(TProxyTileService.ACTION_TILE_TOGGLED),
                RECEIVER_NOT_EXPORTED);
    }
}