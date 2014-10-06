package com.microsoft.researchtracker.sharepoint.models;

import com.microsoft.researchtracker.sharepoint.SPETag;
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

    public ResearchReferenceModel() {
        mData = new SPObject();
    }

    public SPETag getODataETag() {
        return mData.getETagField("odata.etag");
    }

    public int getId() {
        return mData.getIntField("ID");
    }

    public String getProjectId() {
        return mData.getStringField("Project");
    }

    public void setProjectId(String projectId) {
        mData.setField("Project", projectId);
    }

    public SPUrl getURL() {
        return mData.getUrlField("URL");
    }

    public void setURL(SPUrl value) {
        mData.setField("URL", value);
    }

    public String getNotes() {
        return mData.getStringField("Comments");
    }

    public void setNotes(String value) {
        mData.setField("Comments", value);
    }

    public SPObject getInternalData() {
        return mData;
    }
}
