package com.github.anyportal.anyportal;

import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.service.quicksettings.TileService;

public class TProxyTileBootReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            // Request the TileService to listen to state changes after boot
            TileService.requestListeningState(context, 
                new ComponentName(context, TProxyTileService.class));
        }
    }
}