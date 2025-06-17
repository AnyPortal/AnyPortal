package com.github.anyportal.anyportal;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;

import java.io.File;

import libv2raymobile.Libv2raymobile;


public class LibV2rayService extends Service{
    private static final String TAG = "LibV2rayService";
    private libv2raymobile.CoreManager coreManager;

    private final IBinder binder = new LocalBinder();

    public class LocalBinder extends Binder {
        public LibV2rayService getService() {
            return LibV2rayService.this;
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return START_STICKY;
    }

    @Override
    public void onCreate() {
        Log.d(TAG, "starting: onCreate");
        super.onCreate();
        File libAssetFolder = new File(getFilesDir().getParent(), "files/asset");
        String libAssetPath = libAssetFolder.getAbsolutePath();
        File configFile = new File(getFilesDir().getParent(), "files/conf/core.gen.json");

        // Libv2raymobile.setEnv("GODEBUG", "cgocheck=2");
        // Libv2raymobile.setEnv("GOTRACEBACK", "crash");
        
        Libv2raymobile.setEnv("v2ray.location.asset", libAssetPath);
        Libv2raymobile.setEnv("xray.location.asset", libAssetPath);

        coreManager = new libv2raymobile.CoreManager();
        coreManager.runConfig(configFile.getAbsolutePath());
        Log.d(TAG, "finished: onCreate");
    }

    @Override
    public void onDestroy() {
        Log.d(TAG, "starting: onDestroy");
        if (coreManager != null) {
            coreManager.stop();
            coreManager = null;
        }
        super.onDestroy();
        Log.d(TAG, "finished: onDestroy");
        // android.os.Process.killProcess(android.os.Process.myPid());
    }
}
