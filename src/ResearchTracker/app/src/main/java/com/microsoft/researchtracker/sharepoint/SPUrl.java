package com.microsoft.researchtracker.sharepoint;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;

public class SPUrl {

    private JsonObject mData;

    public SPUrl(JsonObject data) {
        mData = data;
    }

    public SPUrl() {
        mData = new JsonObject();
    }

    public String getDescription() {
        return mData.getAsJsonPrimitive("Description").getAsString();
    }

    public void setDescription(String value) {
        mData.add("Description", new JsonPrimitive(value));
    }

    public String getUrl() {
        return mData.getAsJsonPrimitive("Url").getAsString();
    }

    public void setUrl(String value) {
        mData.add("Url", new JsonPrimitive(value));
    }

    public JsonElement toJson() {
        return mData;
    }
}
