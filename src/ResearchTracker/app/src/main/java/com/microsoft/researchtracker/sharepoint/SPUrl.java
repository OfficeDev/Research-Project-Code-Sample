package com.microsoft.researchtracker.sharepoint;

import com.google.gson.JsonObject;

public class SPUrl extends SPObject {

    public SPUrl(JsonObject value) {
        super(value);
    }

    public SPUrl() {
        super();
    }

    public String getTitle() {
        return getStringField("Description");
    }

    public void setTitle(String value) {
        setField("Description", value);
    }

    public String getUrl() {
        return getStringField("Url");
    }

    public void setUrl(String value) {
        setField("Url", value);
    }
}
