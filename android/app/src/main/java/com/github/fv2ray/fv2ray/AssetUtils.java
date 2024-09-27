package com.github.fv2ray.fv2ray;

import android.content.Context;
import android.content.res.AssetManager;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

public class AssetUtils {

    // Method to copy the files from assets to the documents directory
    public static void copyAssetsIfNeeded(Context context) {
        AssetManager assetManager = context.getAssets();
        String[] files = {"geoip.dat", "geosite.dat"};
        File targetDir = new File(context.getFilesDir().getParent(), "app_flutter/fv2ray/asset");

        // Ensure the target directory exists
        if (!targetDir.exists()) {
            targetDir.mkdirs();
        }

        for (String fileName : files) {
            File targetFile = new File(targetDir, fileName);
            // if (!targetFile.exists() || !isSameFile(assetManager, fileName, targetFile)) {
            if (!targetFile.exists()) {
                try {
                    copyAsset(assetManager, fileName, targetFile);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // Check if the file in assets and the target file are the same (size and modified date)
    private static boolean isSameFile(AssetManager assetManager, String assetFileName, File targetFile) {
        try {
            InputStream assetStream = assetManager.open(assetFileName);
            long assetSize = assetStream.available();
            long assetModifiedDate = 0;  // Assets don't have a modified date, so skip this comparison

            long targetFileSize = targetFile.length();
            long targetFileModifiedDate = targetFile.lastModified();

            // Compare size (and optionally date)
            return assetSize == targetFileSize;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Copy the asset file to the target directory
    private static void copyAsset(AssetManager assetManager, String assetFileName, File targetFile) throws IOException {
        InputStream in = assetManager.open(assetFileName);
        FileOutputStream out = new FileOutputStream(targetFile);

        byte[] buffer = new byte[1024];
        int read;
        while ((read = in.read(buffer)) != -1) {
            out.write(buffer, 0, read);
        }

        in.close();
        out.flush();
        out.close();
    }
}