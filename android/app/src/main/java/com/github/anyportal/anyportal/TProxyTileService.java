package com.github.anyportal.anyportal;

import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.os.IBinder;
import android.os.Build;
import android.service.quicksettings.Tile;
import android.service.quicksettings.TileService;

public class TProxyTileService extends TileService {
    public static final String ACTION_TILE_TOGGLED = "com.github.anyportal.anyportal.ACTION_TILE_TOGGLED";
    public static final String EXTRA_IS_ACTIVE = "is_active";

    /// bind TProxyService
    private TProxyService tProxyService = null;
    private ServiceConnection serviceConnection = null;

    private void bindTProxyService(ServiceConnection serviceConnection) {
        Intent intent = new Intent(this, TProxyService.class);
        bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);
    }

    @Override
    public void onStartListening() {
        if (tProxyService != null) {
            updateTileText();
            updateTileState(tProxyService);
        } else {
            if (serviceConnection != null) {
                unbindService(serviceConnection);
            }
            serviceConnection = new ServiceConnection() {
                @Override
                public void onServiceConnected(ComponentName className, IBinder service) {
                    TProxyService.LocalBinder binder = (TProxyService.LocalBinder) service;
                    tProxyService = binder.getService();
                    updateTileText();
                    updateTileState(tProxyService);
                }
        
                @Override
                public void onServiceDisconnected(ComponentName className) {}
            };
            bindTProxyService(serviceConnection);
        }
    }

    @Override
    public void onTileAdded() {
        onStartListening();
    }

    @Override
    public void onDestroy() {
        if (serviceConnection != null) {
            unbindService(serviceConnection);
            serviceConnection = null;
        }
        super.onDestroy();
    }

    public void onClick() {
        super.onClick();

        // Register a receiver to listen for the signal from TProxyTileActivity
        IntentFilter filter = new IntentFilter(TProxyTileActivity.ACTION_DUMMY_ACTIVITY_LAUNCHED);
        registerReceiver(tProxyTileActivityLaunchedReceiver, filter);

        // Launch the TProxyTileActivity
        Intent intent = new Intent(this, TProxyTileActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        // startActivityAndCollapse(intent);  // startActivityAndCollapse minimizes the quick settings panel
        startActivity(intent);
    }

    private void stoggleTProxyService() {
        if (tProxyService != null) {
            toggleTile(tProxyService);
        } else {
            if (serviceConnection != null) {
                unbindService(serviceConnection);
            }
            serviceConnection = new ServiceConnection() {
                @Override
                public void onServiceConnected(ComponentName className, IBinder service) {
                    TProxyService.LocalBinder binder = (TProxyService.LocalBinder) service;
                    tProxyService = binder.getService();
                    toggleTile(tProxyService);
                }
        
                @Override
                public void onServiceDisconnected(ComponentName className) {}
            };
            bindTProxyService(serviceConnection);
        }
    }

    // Define the BroadcastReceiver to listen for the start signal
    private final BroadcastReceiver tProxyTileActivityLaunchedReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            // Start the VPN service here
            stoggleTProxyService();

            // Unregister the receiver after handling the signal
            unregisterReceiver(this);
        }
    };

    public void notifyMainActivity(boolean isExpectingActive) {
        // Send broadcast to notify MainActivity
        Intent broadcastIntent = new Intent(ACTION_TILE_TOGGLED);
        broadcastIntent.putExtra(EXTRA_IS_ACTIVE, isExpectingActive);
        sendBroadcast(broadcastIntent);
    }

    private void updateTileState(TProxyService tProxyService) {
        Tile tile = getQsTile();
        if (tile != null && tProxyService != null) {
            boolean isCoreActive = tProxyService.isCoreActive;
            tile.setState(isCoreActive ? Tile.STATE_ACTIVE : Tile.STATE_INACTIVE);
            tile.updateTile();
        }
    }

    private void updateTileText() {
        Tile tile = getQsTile();
        if (tile == null){
            return;
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            tile.setSubtitle("AnyPortal");
        }

        // Get selected profile from shared preferences
        SharedPreferences prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);
        String selectedProfileName = prefs.getString("flutter.cache.app.selectedProfileName", "AnyPortal");
        // Update tile subtitle with the selected profile
        tile.setLabel(selectedProfileName);
        tile.updateTile();
    }

    private void toggleTile(TProxyService tProxyService) {
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
            tProxyService.tryStopAll();
        } else {
            tile.setState(Tile.STATE_UNAVAILABLE);
            notifyMainActivity(true);
            tProxyService.tryStartAll();
        }

        updateTileState(tProxyService);
    }
}