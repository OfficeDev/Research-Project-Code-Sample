package com.microsoft.researchtracker.sharepoint.models;

import com.microsoft.researchtracker.sharepoint.SPObject;
import com.microsoft.researchtracker.sharepoint.SPUrl;

public class ResearchReferenceModel {

    public static final String[] FIELDS = {
        "ID", "Project", "URL", "Comments"
    };

    private SPObject mData;

    public ResearchReferenceModel(SPObject data) {

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
