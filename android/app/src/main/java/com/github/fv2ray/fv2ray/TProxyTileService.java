package com.github.fv2ray.fv2ray;

import android.app.ActivityManager;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.service.quicksettings.Tile;
import android.service.quicksettings.TileService;

public class TProxyTileService extends TileService {
    public static final String ACTION_TILE_TOGGLED = "com.github.fv2ray.fv2ray.TILE_TOGGLED";
    public static final String EXTRA_IS_ACTIVE = "is_active";

    @Override
    public void onStartListening() {
        Tile tile = getQsTile();

        // Get selected profile from shared preferences
        SharedPreferences prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);

        String selectedProfileName = prefs.getString("flutter.app.selectedProfileName", "");

        // Update tile subtitle with the selected profile
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            tile.setSubtitle(selectedProfileName);
        }

        // Check if the service is running and update the tile state
        if (isServiceRunning()) {
            tile.setState(Tile.STATE_ACTIVE);
        } else {
            tile.setState(Tile.STATE_INACTIVE);
        }

        tile.setLabel("fv2ray");
        tile.updateTile();
    }

    @Override
    public void onClick() {
        Tile tile = getQsTile();

        // Toggle the state based on the current state
        if (tile.getState() == Tile.STATE_INACTIVE) {
            // Start TProxyService
            Intent intent = new Intent(this, TProxyService.class);
            intent.setAction(TProxyService.ACTION_CONNECT);
            startService(intent);

            // Set the tile to active
            tile.setState(Tile.STATE_ACTIVE);
        } else {
            // Stop TProxyService
            Intent intent = new Intent(this, TProxyService.class);
            intent.setAction(TProxyService.ACTION_DISCONNECT);
            startService(intent);

            // Set the tile to inactive
            tile.setState(Tile.STATE_INACTIVE);
        }

        // Send broadcast to notify MainActivity
        Intent broadcastIntent = new Intent(ACTION_TILE_TOGGLED);
        broadcastIntent.putExtra(EXTRA_IS_ACTIVE, !isServiceRunning());
        sendBroadcast(broadcastIntent);

        tile.updateTile();
    }

    private boolean isServiceRunning() {
        ActivityManager manager = (ActivityManager) getSystemService(ACTIVITY_SERVICE);
        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
            if (TProxyService.class.getName().equals(service.service.getClassName())) {
                return true;
            }
        }
        return false;
    }
}