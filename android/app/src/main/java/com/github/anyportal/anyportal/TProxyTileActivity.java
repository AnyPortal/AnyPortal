package com.github.anyportal.anyportal;

import android.app.Activity;
import android.content.Intent;
import android.net.VpnService;
import android.os.Bundle;
import android.util.Log;

public class TProxyTileActivity extends Activity {
    public static final String ACTION_DUMMY_ACTIVITY_LAUNCHED = "com.github.anyportal.anyportal.ACTION_DUMMY_ACTIVITY_LAUNCHED";
    private static final String TAG = "TProxyTileActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "start target: TProxyTileActivity");

        // must prepare VpnService for subsequent VpnService.Builder().establish() to work properly
		Intent intent = VpnService.prepare(TProxyTileActivity.this);
		if (intent != null) {
            startActivityForResult(intent, 0);
        } else {
            onActivityResult(0, RESULT_OK, null);
        }
        
        // Send a broadcast back to the TileService to signal that it can proceed
        intent = new Intent(ACTION_DUMMY_ACTIVITY_LAUNCHED);
        sendBroadcast(intent);
        
        Log.d(TAG, "stop target: TProxyTileActivity");
        // Close this activity immediately
        finish();
    }
}