package com.github.anyportal.anyportal;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;

import java.io.File;

import libv2raymobile.Libv2raymobile;


public class LibV2RayService extends Service{
    private static final String TAG = "LibV2RayService";
    // public static final String ACTION_STOP_LIBV2RAYSERVICE = "com.github.anyportal.anyportal.ACTION_STOP_LIBV2RAYSERVICE";
    private libv2raymobile.CoreManager coreManager;

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
        // if (intent != null && ACTION_STOP_LIBV2RAYSERVICE.equals(intent.getAction())) {
        //     stopCore();
        //     return START_NOT_STICKY;
        // }

        startCore();
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
        stopCore();
        super.onDestroy();
        Log.d(TAG, "finished: onDestroy");
        // android.os.Process.killProcess(android.os.Process.myPid());
    }

    private void startCore() {
        File configFile = new File(getFilesDir().getParent(), "files/conf/core.gen.json");
        coreManager = new libv2raymobile.CoreManager();
        coreManager.runConfig(configFile.getAbsolutePath());
    }

    private void stopCore() {
        if (coreManager != null) {
            coreManager.stop();
            coreManager = null;
        }
    }
}
