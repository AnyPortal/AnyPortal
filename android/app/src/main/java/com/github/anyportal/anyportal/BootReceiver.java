package com.github.anyportal.anyportal;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.net.VpnService;
import android.os.IBinder;
import android.service.quicksettings.TileService;
// import android.widget.Toast;

public class BootReceiver extends BroadcastReceiver {
    private SharedPreferences prefs;

    @Override
    public void onReceive(Context context, Intent intent) {
        // Toast.makeText(context, "Boot Completed Received", Toast.LENGTH_LONG).show();

        // Request the TileService to listen to state changes after boot
        TileService.requestListeningState(context, 
            new ComponentName(context, TProxyTileService.class));

        prefs = context.getSharedPreferences("FlutterSharedPreferences", context.MODE_PRIVATE);

        if (prefs.getBoolean("flutter.app.connectAtStartup", false)){
            launchTProxyService(context);
        }
    }

    private void launchTProxyService(Context context) {
        ServiceConnection serviceConnection = new ServiceConnection() {
            @Override
            public void onServiceConnected(ComponentName className, IBinder service) {
                TProxyService.LocalBinder binder = (TProxyService.LocalBinder) service;
                TProxyService tProxyService = binder.getService();
                tProxyService.tryStartAll();
            }
    
            @Override
            public void onServiceDisconnected(ComponentName className) {}
        };
        Intent intent = new Intent(context, TProxyService.class);
        context.getApplicationContext().bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);
    }
}