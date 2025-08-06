package com.github.anyportal.anyportal;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import libv2raymobile.Libv2raymobile;

public class LibV2RayService extends Service {
    private static final String TAG = "LibV2RayService";
    public static final String ACTION_STOP_CORE = "com.github.anyportal.anyportal.ACTION_STOP_CORE";

    private Map<String, libv2raymobile.CoreManager> coreManagers = new HashMap<String, libv2raymobile.CoreManager>();

    private final IBinder binder = new LocalBinder();

    public class LocalBinder extends Binder {
        public LibV2RayService getService() {
            return LibV2RayService.this;
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        String configPath = null;
        if (intent != null) {
            final String intentConfigPath = intent.getStringExtra("configPath");
            if (intentConfigPath != null) {
                configPath = intentConfigPath;
            }
            if (ACTION_STOP_CORE.equals(intent.getAction())) {
                stopCore(configPath);
                return START_STICKY;
            }
        }

        startCore(configPath);
        return START_STICKY;
    }

    @Override
    public void onCreate() {
        Log.d(TAG, "starting: onCreate");
        super.onCreate();
        File libAssetFolder = new File(getFilesDir().getParent(), "files/asset");
        String libAssetPath = libAssetFolder.getAbsolutePath();

        // Libv2raymobile.setEnv("GODEBUG", "cgocheck=2");
        // Libv2raymobile.setEnv("GOTRACEBACK", "crash");

        Libv2raymobile.setEnv("v2ray.location.asset", libAssetPath);
        Libv2raymobile.setEnv("xray.location.asset", libAssetPath);
        Log.d(TAG, "finished: onCreate");
    }

    @Override
    public void onDestroy() {
        Log.d(TAG, "starting: onDestroy");
        for (String configPath : coreManagers.keySet()) {
            stopCore(configPath);
        }
        super.onDestroy();
        Log.d(TAG, "finished: onDestroy");
        // android.os.Process.killProcess(android.os.Process.myPid());
    }

    private void startCore(String configPath) {
        File configFile;
        if (configPath != null) {
            configFile = new File(configPath);
        } else {
            configFile = new File(getFilesDir().getParent(), "files/conf/core.gen.json");
        }
        libv2raymobile.CoreManager coreManager = new libv2raymobile.CoreManager();
        coreManagers.put(configPath, coreManager);
        coreManager.runConfig(configFile.getAbsolutePath());
    }

    private void stopCore(String configPath) {
        if (coreManagers.containsKey(configPath)) {
            coreManagers.get(configPath).stop();
            coreManagers.remove(configPath);
        }
    }
}
