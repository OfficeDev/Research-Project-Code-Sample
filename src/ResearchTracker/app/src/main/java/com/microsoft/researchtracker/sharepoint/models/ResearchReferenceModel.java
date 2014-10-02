package com.microsoft.researchtracker.sharepoint.models;

import com.microsoft.researchtracker.sharepoint.SPODataObject;
import com.microsoft.researchtracker.sharepoint.SPUrl;

public class ResearchReferenceModel {
    private SPODataObject mData;

    public ResearchReferenceModel(SPODataObject data) {

        mData = data;
    }

    public int getId() {
        return mData.getIntField("ID");
    }

    public int getProjectId() {
        return mData.getIntField("Project");
    }

    public SPUrl getURL() {
        return mData.getUrlField("URL");
    }

    public String getNotes() {
        return mData.getStringField("Comments");
    }
}
