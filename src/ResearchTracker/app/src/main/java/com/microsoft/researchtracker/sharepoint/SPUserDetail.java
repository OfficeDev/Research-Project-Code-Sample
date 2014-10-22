package com.microsoft.researchtracker.sharepoint;

import com.google.gson.JsonObject;

public class SPUserDetail extends SPObject {

    public SPUserDetail(JsonObject value) {
        super(value);
    }

    public SPUserDetail() {
        super();
    }

    public String getDisplayName() {
        return getStringField("Title");
    }

    public void setTitle(String value) {
        setField("Title", value);
    }

}
