package com.microsoft.researchtracker.sharepoint;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class SPODataCollection {

    private JsonObject mData;

    public SPODataCollection(JsonObject data) {
        mData = data;
    }

    public String getODataMetadata() {
        JsonPrimitive el = mData.getAsJsonPrimitive("odata.metadata");
        return (el != null && el.isString()) ? el.getAsString() : null;
    }

    public List<SPODataObject> getValue() {

        final JsonArray arr = mData.getAsJsonArray("value");

        if (arr == null)
            return Collections.emptyList();

        final List<SPODataObject> values = new ArrayList<SPODataObject>();

        for (JsonElement el : arr) {
            if (el.isJsonObject()) {
                values.add(new SPODataObject(el.getAsJsonObject()));
            }
        }

        return values;
    }
}
