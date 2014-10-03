package com.microsoft.researchtracker.sharepoint;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class SPCollection {

    private JsonObject mData;

    public SPCollection(JsonObject data) {
        mData = data;
    }

    public String getODataMetadata() {
        JsonPrimitive el = mData.getAsJsonPrimitive("odata.metadata");
        return (el != null && el.isString()) ? el.getAsString() : null;
    }

    public List<SPObject> getValue() {

        final JsonArray arr = mData.getAsJsonArray("value");

        if (arr == null)
            return Collections.emptyList();

        final List<SPObject> values = new ArrayList<SPObject>();

        for (JsonElement el : arr) {
            if (el.isJsonObject()) {
                values.add(new SPObject(el.getAsJsonObject()));
            }
        }

        return values;
    }
}
