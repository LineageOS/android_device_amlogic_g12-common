/*
 * Copyright (C) 2022 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.settings.device;

import android.os.Bundle;

import androidx.preference.Preference;
import androidx.preference.PreferenceFragment;
import androidx.preference.SwitchPreference;

import com.droidlogic.app.SystemControlManager;

public class ColorSpaceSettingsFragment extends PreferenceFragment
        implements Preference.OnPreferenceChangeListener {

    private static String KEY_RGB_COLORSPACE = "rgb_color_space";
    private static String PROPERTY_HDMI_COLORSPACE = "ubootenv.var.hdmi_colorspace";
    private static String COLORSPACE_RGB = "rgb,10bit";
    private static String COLORSPACE_DEFAULT = "444,8bit";

    private SystemControlManager mSystemControlManager;

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        addPreferencesFromResource(R.xml.color_space_settings);
        getActivity().getActionBar().setDisplayHomeAsUpEnabled(true);

        mSystemControlManager = SystemControlManager.getInstance();
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        if (KEY_RGB_COLORSPACE.equals(preference.getKey())) {
            boolean enabled = (boolean) newValue;
            mSystemControlManager.setBootenv(PROPERTY_HDMI_COLORSPACE,
                    enabled ? COLORSPACE_RGB : COLORSPACE_DEFAULT);

            return true;
        }

        return false;
    }
}
