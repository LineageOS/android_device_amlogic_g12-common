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
import android.view.KeyEvent;

import android.util.Log;

import com.android.internal.os.DeviceKeyHandler;

public class KeyHandler implements DeviceKeyHandler {
    private static final String TAG = KeyHandler.class.getSimpleName();

    // Button key codes
    private static final int KEY_NETFLIX = 251;
    private static final int KEY_YOUTUBE = 250;
    private static final int KEY_GPLAY = 252;

    // Packages
    private static final String PACKAGE_NETFLIX = "com.netflix.mediaclient";
    private static final String PACKAGE_YOUTUBE = "com.google.android.youtube.tv";
    private static final String PACKAGE_GPLAY = "com.android.vending";

    private final Context mContext;

    public KeyHandler(Context context) {
        mContext = context;
    }

    public KeyEvent handleKeyEvent(KeyEvent event) {
        if (event.getAction() != KeyEvent.ACTION_DOWN) {
            return event;
        }

        int scanCode = event.getScanCode();

        switch (scanCode) {
            case KEY_NETFLIX:
                launchActivity(PACKAGE_NETFLIX);
                break;
            case KEY_YOUTUBE:
                launchActivity(PACKAGE_YOUTUBE);
                break;
            case KEY_GPLAY:
                launchActivity(PACKAGE_GPLAY);
                break;
            default:
                return event;
        }
        return null;
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
