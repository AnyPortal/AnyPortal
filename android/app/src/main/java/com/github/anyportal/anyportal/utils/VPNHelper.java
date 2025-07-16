package com.github.anyportal.anyportal.utils;

import android.app.Activity;
import android.content.Intent;
import android.net.VpnService;

public class VPNHelper {
    private static Runnable onPermissionGranted;

    public static boolean ensureVPNPermission(Activity activity, int requestCode, Runnable onGranted) {
        onPermissionGranted = onGranted;
        Intent intent = VpnService.prepare(activity);
        if (intent != null) {
            activity.startActivityForResult(intent, requestCode);
            return false;
        } else {
            // Permission already granted — run immediately.
            if (onGranted != null) {
                onGranted.run();
            }
            return true;
        }
    }

    public static void handleActivityResult(int requestCode, int resultCode, int expectedRequestCode) {
        if (requestCode == expectedRequestCode && resultCode == Activity.RESULT_OK && onPermissionGranted != null) {
            onPermissionGranted.run();
            onPermissionGranted = null; // clear reference
        }
    }
}