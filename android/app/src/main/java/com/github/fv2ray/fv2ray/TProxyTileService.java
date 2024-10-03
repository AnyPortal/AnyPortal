package com.github.fv2ray.fv2ray;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.os.IBinder;
import android.os.Build;
import android.service.quicksettings.Tile;
import android.service.quicksettings.TileService;

public class TProxyTileService extends TileService {
    public static final String ACTION_TILE_TOGGLED = "com.github.fv2ray.fv2ray.TILE_TOGGLED";
    public static final String EXTRA_IS_ACTIVE = "is_active";



    /// bind TProxyService
    private TProxyService tProxyService;
    private boolean bound = false;

    private final ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName className, IBinder service) {
            TProxyService.LocalBinder binder = (TProxyService.LocalBinder) service;
            tProxyService = binder.getService();
            bound = true;
            updateTileState();
        }

        @Override
        public void onServiceDisconnected(ComponentName arg0) {
            bound = false;
        }
    };

    private void bindTProxyService() {
        if (!bound) {
            Intent intent = new Intent(this, TProxyService.class);
            bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);
        }
    }




    @Override
    public void onTileAdded() {
        bindTProxyService();
    }

    @Override
    public void onStartListening() {
        bindTProxyService();

        Tile tile = getQsTile();
        if (tile == null){
            return;
        }
        
        // Update tile subtitle with the selected profile
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Get selected profile from shared preferences
            SharedPreferences prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);
            String selectedProfileName = prefs.getString("flutter.app.selectedProfileName", "");
            tile.setSubtitle(selectedProfileName);
        }

        tile.setLabel("fv2ray");
        tile.updateTile();
    }

    public void onClick() {
        if (tProxyService == null) {
            return;
        }

        Tile tile = getQsTile();
        if (tile == null){
            return;
        }


        if (tile.getState() == Tile.STATE_ACTIVE) {
            tile.setState(Tile.STATE_UNAVAILABLE);
            notifyMainActivity(false);
            stopTProxy();
        } else {
            tile.setState(Tile.STATE_UNAVAILABLE);
            notifyMainActivity(true);
            startTProxy();
        }

        updateTileState();
    }

    private void startTProxy() {
        if (tProxyService != null) {
            tProxyService.startTProxy();
        }
    }

    private void stopTProxy() {
        if (tProxyService != null) {
            tProxyService.stopTProxy();
        }
    }

    public void notifyMainActivity(boolean isExpectingActive) {
        // Send broadcast to notify MainActivity
        Intent broadcastIntent = new Intent(ACTION_TILE_TOGGLED);
        broadcastIntent.putExtra(EXTRA_IS_ACTIVE, isExpectingActive);
        sendBroadcast(broadcastIntent);
    }

    private void updateTileState() {
        Tile tile = getQsTile();
        if (tile != null && tProxyService != null) {
            boolean isActive = tProxyService.getIsActive();
            tile.setState(isActive ? Tile.STATE_ACTIVE : Tile.STATE_INACTIVE);
            tile.updateTile();
        }
    }
}