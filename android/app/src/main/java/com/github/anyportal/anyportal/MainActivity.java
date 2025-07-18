package com.github.anyportal.anyportal;

import com.github.anyportal.anyportal.utils.AssetUtils;
import com.github.anyportal.anyportal.utils.VPNHelper;

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
import java.util.HashMap;
import java.util.Map;

import org.json.JSONObject;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.github.anyportal.anyportal";
    private static MethodChannel methodChannel;
    private static final String TAG = "MainActivity";
    private static final int VPN_REQUEST_CODE = 1;

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
        intent.setAction(TProxyService.ACTION_NULL);
        bindService(intent, tProxyServiceConnection, Context.BIND_AUTO_CREATE);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Copy geoip.dat and geosite.dat to the documents directory if needed
        AssetUtils.copyAssetsIfNeeded(this);
    }

    @Override
    protected void onResume() {
        super.onResume();
        for (FileObserver fileObserver : fileObservers.values()) {
            if (fileObserver != null) {
                fileObserver.startWatching();
            }
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        for (FileObserver fileObserver : fileObservers.values()) {
            if (fileObserver != null) {
                fileObserver.stopWatching();
            }
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (tProxyServiceConnection != null) {
            unbindService(tProxyServiceConnection);
            tProxyServiceConnection = null;
        }
    }

    @Override
    public void onTrimMemory(int level) {
        super.onTrimMemory(level);
        methodChannel.invokeMethod("onTrimMemory", level);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        VPNHelper.handleActivityResult(requestCode, resultCode, VPN_REQUEST_CODE);
    }

    /// bind TProxyService
    private TProxyService tProxyService;

    public class TProxyServiceStatusChangeListener implements TProxyService.StatusChangeListener {
        @Override
        public void onAllStatusChange(boolean isCoreActive) {
            runOnUiThread(() -> {
                methodChannel.invokeMethod("onAllStatusChange", isCoreActive);
            });
        };

        @Override
        public void onCoreStatusChange(boolean isCoreActive) {
            runOnUiThread(() -> {
                methodChannel.invokeMethod("onCoreStatusChange", isCoreActive);
            });
        };

        @Override
        public void onTunStatusChange(boolean isTunActive) {
            runOnUiThread(() -> {
                methodChannel.invokeMethod("onTunStatusChange", isTunActive);
            });
        };

        @Override
        public void onSystemProxyStatusChange(boolean isSystemProxyActive) {
            runOnUiThread(() -> {
                methodChannel.invokeMethod("onSystemProxyStatusChange", isSystemProxyActive);
            });
        };
    }

    private ServiceConnection tProxyServiceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName className, IBinder service) {
            TProxyService.LocalBinder binder = (TProxyService.LocalBinder) service;
            tProxyService = binder.getService();

            // Set the status listener to receive updates
            tProxyService.setStatusChangeListener(new TProxyServiceStatusChangeListener());
        }

        @Override
        public void onServiceDisconnected(ComponentName arg0) {
        }
    };

    Map<String, FileObserver> fileObservers = new HashMap<String, FileObserver>();

    private void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "vpn.startAll":
                VPNHelper.ensureVPNPermission(this, VPN_REQUEST_CODE, new Runnable() {
                    @Override
                    public void run() {
                        tProxyService.tryStartAll();
                    }
                });
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
                VPNHelper.ensureVPNPermission(this, VPN_REQUEST_CODE, new Runnable() {
                    @Override
                    public void run() {
                        tProxyService.tryStartTun();
                    }
                });
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

            case "vpn.isSystemProxyActive":
                result.success(tProxyService.isSystemProxyActive);
                break;

            case "log.core.startWatching": {
                String filePath = call.argument("filePath");
                FileObserver fileObserver = new FileObserver(new File(filePath)) {
                    @Override
                    public void onEvent(int event, String path) {
                        new Handler(Looper.getMainLooper()).post(new Runnable() {
                            @Override
                            public void run() {
                                if (event == FileObserver.MODIFY) {
                                    methodChannel.invokeMethod("onFileChange", filePath);
                                }
                            }
                        });
                    }
                };
                fileObserver.startWatching();
                fileObservers.put(filePath, fileObserver);
                break;
            }

            case "log.core.stopWatching": {
                String filePath = call.argument("filePath");
                if (fileObservers.containsKey(filePath)) {
                    fileObservers.get(filePath).stopWatching();
                }
                break;
            }

            case "os.abis":
                result.success(Arrays.asList(Build.SUPPORTED_ABIS));
                break;

            case "app.osArch":
                result.success(System.getProperty("os.arch"));
                break;

            case "app.targetSdkVersion": {
                int targetSdk = getApplicationInfo().targetSdkVersion;
                result.success(targetSdk);
                break;
            }

            case "os.installApk": {
                String path = call.argument("path");
                installApk(path);
                result.success(null);
                break;
            }

            case "os.getEffectiveLinkProperties":
                new Thread(() -> {
                    JSONObject effectiveLinkProperties = tProxyService.getEffectiveLinkProperties();
                    String res = effectiveLinkProperties != null ? effectiveLinkProperties.toString() : null;

                    new Handler(Looper.getMainLooper()).post(() -> {
                        result.success(res);
                    });
                }).start();
                break;

            default:
                result.notImplemented();
                break;
        }
    }

    private void installApk(String filePath) {
        File apkFile = new File(filePath);
        if (!apkFile.exists())
            return;

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