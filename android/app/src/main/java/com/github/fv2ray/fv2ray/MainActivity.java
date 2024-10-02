package com.github.fv2ray.fv2ray;

import android.app.ActivityManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.VpnService;
import android.os.Bundle;
import android.os.FileObserver;
import android.os.Looper;
import android.os.Handler;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import java.io.File;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.github.fv2ray.fv2ray";
    
    private BroadcastReceiver broadcastReceiver;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        initializeMethodChannels(flutterEngine.getDartExecutor().getBinaryMessenger());
    }

    private void initializeMethodChannels(BinaryMessenger messenger) {
        AppChannelHandler(messenger);
    }

    @Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		/* Request VPN permission */
		Intent intent = VpnService.prepare(MainActivity.this);
		if (intent != null)
		  startActivityForResult(intent, 0);
		else
		  onActivityResult(0, RESULT_OK, null);

        // Copy geoip.dat and geosite.dat to the documents directory if needed
        AssetUtils.copyAssetsIfNeeded(this);
        
        // listen for broadcast
        registerBroadcastReceiver();
	}

    private FileObserver fileObserver;

    public void AppChannelHandler(BinaryMessenger messenger) {
        new MethodChannel(messenger, CHANNEL).setMethodCallHandler(this::onMethodCall);
    }

    private void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("startTProxyService")){
            startTProxyService();
            result.success(null);
        } else if (call.method.equals("stopTProxyService")){
            stopTProxyService();
            result.success(null);
        } else if (call.method.equals("isTProxyServiceRunning")){
            boolean isRunning = isServiceRunning(TProxyService.class);
            result.success(isRunning);
        } else if (call.method.equals("startWatching")){
            String filePath = call.argument("filePath");
            fileObserver = new FileObserver(filePath) {
                @Override
                public void onEvent(int event, String path) {
                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override
                        public void run() {
                            if (event == FileObserver.MODIFY) {
                                new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                                        .invokeMethod("onFileChange", null);
                            }
                        }
                    });
                }
            };
            fileObserver.startWatching();
        } else {
            result.notImplemented();
        }
    }
    

    private void startTProxyService() {
        Intent intent = new Intent(this, TProxyService.class);
        intent.setAction(TProxyService.ACTION_CONNECT);
        startService(intent);
    }

    private void stopTProxyService() {
        Intent intent = new Intent(this, TProxyService.class);
        intent.setAction(TProxyService.ACTION_DISCONNECT);
        startService(intent);
    }

    private boolean setExecutablePermission(String filePath) {
        File file = new File(filePath);
        return file.setExecutable(true);
    }

    public boolean isServiceRunning(Class<?> serviceClass) {
        ActivityManager manager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
            if (serviceClass.getName().equals(service.service.getClassName())) {
                return true;
            }
        }
        return false;
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
        // Unregister the BroadcastReceiver
        unregisterReceiver(broadcastReceiver);
    }

    private void registerBroadcastReceiver() {
        MethodChannel methodChannel = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL);
        broadcastReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String action = intent.getAction();
                if (TProxyTileService.ACTION_TILE_TOGGLED.equals(action)) {
                    boolean isActive = intent.getBooleanExtra(TProxyTileService.EXTRA_IS_ACTIVE, false);
                    methodChannel.invokeMethod("onTileToggled", isActive);
                } else if (TProxyService.ACTION_CONNECTED.equals(action)) {
                    methodChannel.invokeMethod("onVPNConnected", null);
                } else if (TProxyService.ACTION_DISCONNECTED.equals(action)) {
                    methodChannel.invokeMethod("onVPNDisconnected", null);
                }
            }
        };

        registerReceiver(broadcastReceiver, new IntentFilter(TProxyTileService.ACTION_TILE_TOGGLED));
        registerReceiver(broadcastReceiver, new IntentFilter(TProxyService.ACTION_CONNECTED));
        registerReceiver(broadcastReceiver, new IntentFilter(TProxyService.ACTION_DISCONNECTED));
    }
}