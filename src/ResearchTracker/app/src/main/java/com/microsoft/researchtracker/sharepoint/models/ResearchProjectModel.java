package com.microsoft.researchtracker.sharepoint.models;

import com.microsoft.researchtracker.sharepoint.SPETag;
import com.microsoft.researchtracker.sharepoint.SPObject;

public class ResearchProjectModel {

    public static final String[] FIELDS = {
        "ID", "Title"
    };
    private SPObject mData;

    public ResearchProjectModel(SPObject data) {
        mData = data;
    }

    public ResearchProjectModel() {
        mData = new SPObject();
    }

    public SPETag getODataEtag() {
        return mData.getETagField("odata.etag");
    }

    public int getId() {
        return mData.getIntField("ID");
    }

    public void setId(int value) {
        mData.setField("ID", value);
    }

    public String getTitle() {
        return mData.getStringField("Title");
    }

    public void setTitle(String value) {
        mData.setField("Title", value);
    }

    public SPObject getInternalData() {
        return mData;
    }
}
