package com.github.fv2ray.fv2ray;

import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
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
}