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

    public int getProjectId() {
        return mData.getIntField("Project");
    }

    public void setProjectId(int projectId) {
        mData.setField("Project", Integer.toString(projectId));
    }

    public SPUrl getURL() {
        return mData.getUrlField("URL");
    }

    public void setURL(SPUrl value) {
        mData.setField("URL", value);
    }

    public String getDescription() {
        return mData.getStringField("Comments");
    }

    public void setDescription(String value) {
        mData.setField("Comments", value);
    }

    public SPObject getInternalData() {
        return mData;
    }
}
