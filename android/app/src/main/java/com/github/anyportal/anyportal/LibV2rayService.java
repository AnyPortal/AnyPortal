package com.github.anyportal.anyportal;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;

import androidx.annotation.Nullable;

import java.io.File;

import libv2raymobile.Libv2raymobile;


public class LibV2rayService extends Service{
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
    public void onCreate() {
        File libAssetFolder = new File(getFilesDir().getParent(), "files/asset");
        String libAssetPath = libAssetFolder.getAbsolutePath();
        File configFile = new File(getFilesDir().getParent(), "files/conf/core.gen.json");

        Libv2raymobile.setEnv("v2ray.location.asset", libAssetPath);
        Libv2raymobile.setEnv("xray.location.asset", libAssetPath);
        coreManager = new libv2raymobile.CoreManager();
        coreManager.runConfig(configFile.getAbsolutePath());
    }

    @Override
    public void onDestroy() {
        if (coreManager != null) {
            coreManager.stop();
            coreManager = null;
        }
        android.os.Process.killProcess(android.os.Process.myPid());
    }
}
