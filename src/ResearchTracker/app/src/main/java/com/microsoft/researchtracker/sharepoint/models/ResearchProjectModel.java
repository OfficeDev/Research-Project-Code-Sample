package com.microsoft.researchtracker.sharepoint.models;

import com.microsoft.researchtracker.sharepoint.SPODataObject;

public class ResearchProjectModel {
    private SPODataObject mData;

    public ResearchProjectModel(SPODataObject data) {

        mData = data;
    }

    public int getId() {
        return mData.getIntField("ID");
    }

    public String getTitle() {
        return mData.getStringField("Title");
    }
}
