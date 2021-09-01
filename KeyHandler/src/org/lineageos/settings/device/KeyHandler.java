/*
 * Copyright (C) 2021 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.lineageos.settings.device;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.SystemProperties;
import android.util.Log;
import android.view.KeyEvent;

import java.util.HashMap;
import java.util.Map;

import com.android.internal.os.DeviceKeyHandler;

public class KeyHandler implements DeviceKeyHandler {
    private static final String TAG = KeyHandler.class.getSimpleName();

    private static Map<Integer, String> KEYMAP = new HashMap<>();

    // Button key codes
    private static final int DOPINDER_KEY_YOUTUBE = 240;
    /* For some reason dopinder reports 240 for both YouTube/Netflix */
    /* So we will use the more useful of the two, YouTube. */
    private static final int DOPINDER_KEY_NETFLIX = 241;
    private static final int DOPINDER_KEY_DISNEY = 230;
    private static final int DOPINDER_KEY_HBOMAX = 229;
    private static final int DOPINDER_KEY_TV_SETTINGS = 384;

    private static final int SABRINA_KEY_YOUTUBE = 250;
    private static final int SABRINA_KEY_NETFLIX = 251;

    private static final int WADE_KEY_YOUTUBE = 250;
    private static final int WADE_KEY_NETFLIX = 251;
    private static final int WADE_KEY_GPLAY = 252;

    // Packages
    private static final String PACKAGE_YOUTUBE = "com.google.android.youtube.tv";
    private static final String PACKAGE_NETFLIX = "com.netflix.mediaclient";
    private static final String PACKAGE_GPLAY = "com.android.vending";
    private static final String PACKAGE_DISNEY = "com.disney.disneyplus";
    private static final String PACKAGE_HBOMAX = "com.hbo.hbonow";
    private static final String PACKAGE_TV_SETTINGS = "com.android.tv.settings";

    private final Context mContext;

    static {
        switch (SystemProperties.get("ro.lineage.device", "")) {
            case "dopinder":
                KEYMAP.put(DOPINDER_KEY_YOUTUBE, PACKAGE_YOUTUBE);
                KEYMAP.put(DOPINDER_KEY_NETFLIX, PACKAGE_NETFLIX);
                KEYMAP.put(DOPINDER_KEY_DISNEY, PACKAGE_DISNEY);
                KEYMAP.put(DOPINDER_KEY_HBOMAX, PACKAGE_HBOMAX);
                KEYMAP.put(DOPINDER_KEY_TV_SETTINGS, PACKAGE_TV_SETTINGS);
                break;
            case "sabrina":
                KEYMAP.put(SABRINA_KEY_YOUTUBE, PACKAGE_YOUTUBE);
                KEYMAP.put(SABRINA_KEY_NETFLIX, PACKAGE_NETFLIX);
            case "wade":
                KEYMAP.put(WADE_KEY_YOUTUBE, PACKAGE_YOUTUBE);
                KEYMAP.put(WADE_KEY_NETFLIX, PACKAGE_NETFLIX);
                KEYMAP.put(WADE_KEY_GPLAY, PACKAGE_GPLAY);
                break;
            default:
                Log.e(TAG, "Device model for KeyHandler not found!");
                break;
        }
    }

    public KeyHandler(Context context) {
        mContext = context;
    }

    public KeyEvent handleKeyEvent(KeyEvent event) {
        if (event.getAction() != KeyEvent.ACTION_DOWN) {
            return event;
        }

        int scanCode = event.getScanCode();
        String packageName = KEYMAP.get(scanCode);

        if (packageName != null) {
            launchActivity(packageName);
            return null;
        }

        return event;
    }

    private void launchActivity(String packageName) {
        Intent launchIntent = mContext.getPackageManager()
                .getLaunchIntentForPackage(packageName);
        if (launchIntent != null) {
            mContext.startActivity(launchIntent);
        } else {
            Log.w(TAG, "Cannot launch " + packageName +
                    ": package not found.");
        }
    }
}
