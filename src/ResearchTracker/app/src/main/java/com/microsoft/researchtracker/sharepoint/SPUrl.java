package com.microsoft.researchtracker.sharepoint;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

public class SPUrl {

    private JsonObject mData;

    public SPUrl(JsonObject data) {
        mData = data;
    }

    public String getDescription() {
        return mData.getAsJsonPrimitive("Description").getAsString();
    }

    public String getUrl() {
        return mData.getAsJsonPrimitive("Url").getAsString();
    }

    public JsonElement toJson() {
        return mData;
    }
}
