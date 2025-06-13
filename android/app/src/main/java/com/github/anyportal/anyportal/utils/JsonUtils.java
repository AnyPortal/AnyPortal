package com.github.anyportal.anyportal.utils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


public class JsonUtils {
    public static List<String> getStringListFromJsonString(String str) {
        List<String> res = new ArrayList<>();
        try {
            JSONArray jsonArray = new JSONArray(str);
            for (int i = 0; i < jsonArray.length(); i++) {
                res.add(jsonArray.getString(i));
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return res;
    }

    public static Map<String, String> getStringStringMapFromJsonString(String str) {
        Map<String, String> res = new HashMap<String, String>();
        try {
            JSONObject jsonObject = new JSONObject(str);
            Iterator<String> keys = jsonObject.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                String value = jsonObject.getString(key);
                res.put(key, value);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return res;
    }
}
