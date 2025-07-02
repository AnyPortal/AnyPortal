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

public class MainTileService extends TileService {
    /// bind TProxyService
    private TProxyService tProxyService = null;
    private ServiceConnection serviceConnection = null;

    private void bindTProxyService(ServiceConnection serviceConnection) {
        Intent intent = new Intent(getApplicationContext(), TProxyService.class);
        intent.setAction(TProxyService.ACTION_NULL);
        bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);
    }

    @Override
    public void onStartListening() {
        if (tProxyService != null) {
            updateTileText();
            onTProxyServiceReady(tProxyService);
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
                    onTProxyServiceReady(tProxyService);
                }

                @Override
                public void onServiceDisconnected(ComponentName className) {
                }
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
        toggleTProxyService();
    }

    private void toggleTProxyService() {
        connectTProxyService(getApplicationContext());
    }

    private void connectTProxyService(Context context) {
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
                public void onServiceDisconnected(ComponentName className) {
                }
            };
            bindTProxyService(serviceConnection);
        }
    }

    private void onTProxyServiceReady(TProxyService tProxyService) {
        Tile tile = getQsTile();
        if (tile != null && tProxyService != null) {
            boolean isCoreActive = tProxyService.isCoreActive;
            tile.setState(isCoreActive ? Tile.STATE_ACTIVE : Tile.STATE_INACTIVE);
            tile.updateTile();
        }
    }

    private void updateTileText() {
        Tile tile = getQsTile();
        if (tile == null) {
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
        if (tile == null) {
            return;
        }

        if (tile.getState() == Tile.STATE_ACTIVE) {
            tile.setState(Tile.STATE_UNAVAILABLE);
            tProxyService.tryStopAll();
        } else {
            tile.setState(Tile.STATE_UNAVAILABLE);
            tProxyService.tryStartAll();
        }

        onTProxyServiceReady(tProxyService);
    }
}