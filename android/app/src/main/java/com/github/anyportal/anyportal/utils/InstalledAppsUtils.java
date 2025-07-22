package com.github.anyportal.anyportal.utils;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.graphics.Canvas;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class InstalledAppsUtils {
    public static List<Map<String, Object>> getInstalledApps(Context context, List<String> requestedFields) {
        PackageManager pm = context.getPackageManager();
        List<PackageInfo> packages = pm.getInstalledPackages(0);
        List<Map<String, Object>> apps = new ArrayList<>();

        Set<String> iconCacheNames = new HashSet<>();

        File iconDir = new File(context.getCacheDir(), "installed_app_icons");
        if (!iconDir.exists())
            iconDir.mkdirs();

        for (PackageInfo packageInfo : packages) {
            String packageName = packageInfo.packageName;
            Map<String, Object> app = new HashMap<>();

            app.put("packageName", packageName);

            if (requestedFields.contains("applicationLabel")) {
                try {
                    String applicationLabel = pm.getApplicationLabel(packageInfo.applicationInfo).toString();
                    app.put("applicationLabel", applicationLabel);
                } catch (Exception ignored) {
                }
            }

            if (requestedFields.contains("flagSystem")) {
                boolean flagSystem = (packageInfo.applicationInfo.flags & ApplicationInfo.FLAG_SYSTEM) != 0;
                app.put("flagSystem", flagSystem);
            }

            long firstInstallTime = packageInfo.firstInstallTime;
            if (requestedFields.contains("firstInstallTime")) {
                app.put("firstInstallTime", firstInstallTime);
            }

            long lastUpdateTime = packageInfo.lastUpdateTime;
            if (requestedFields.contains("lastUpdateTime")) {
                app.put("lastUpdateTime", lastUpdateTime);
            }

            if (requestedFields.contains("iconPath")) {
                String iconFileName = packageName + "_" + lastUpdateTime + ".png";
                iconCacheNames.add(iconFileName);
                File iconFile = new File(iconDir, iconFileName);

                try {
                    if (!iconFile.exists()) {
                        Drawable icon = pm.getApplicationIcon(packageInfo.applicationInfo);
                        Bitmap bitmap = drawableToBitmap(icon);
                        FileOutputStream out = new FileOutputStream(iconFile);
                        bitmap.compress(Bitmap.CompressFormat.PNG, 100, out);
                        out.flush();
                        out.close();
                    }
                    app.put("iconPath", iconFile.getAbsolutePath());
                } catch (Exception ignored) {
                }
            }

            apps.add(app);
        }

        new Thread(() -> cleanupOldIcons(iconDir, iconCacheNames)).start();

        return apps;
    }

    private static Bitmap drawableToBitmap(Drawable drawable) {
        if (drawable instanceof android.graphics.drawable.BitmapDrawable) {
            return ((android.graphics.drawable.BitmapDrawable) drawable).getBitmap();
        }

        int width = drawable.getIntrinsicWidth() > 0 ? drawable.getIntrinsicWidth() : 1;
        int height = drawable.getIntrinsicHeight() > 0 ? drawable.getIntrinsicHeight() : 1;

        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        drawable.draw(canvas);
        return bitmap;
    }

    private static void cleanupOldIcons(File iconDir, Set<String> iconCacheNames) {
        File[] files = iconDir.listFiles();
        if (files == null)
            return;

        for (File file : files) {
            if (!iconCacheNames.contains(file.getName())) {
                file.delete();
            }
        }
    }
}
