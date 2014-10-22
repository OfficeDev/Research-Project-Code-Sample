package com.microsoft.researchtracker.sharepoint.models;

import com.microsoft.researchtracker.sharepoint.SPETag;
import com.microsoft.researchtracker.sharepoint.SPObject;
import com.microsoft.researchtracker.sharepoint.SPUserDetail;

import java.util.Date;

public class ResearchProjectModel {

    public static final String[] SELECT = {
        "ID", "Title", "Modified", "Editor/Title"
    };
    
    public static final String[] EXPAND = {
        "Editor"
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

    public SPUserDetail getEditor() {
        return mData.getUserDetailField("Editor");
    }

    public Date getModified() { return mData.getDateField("Modified"); }

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
