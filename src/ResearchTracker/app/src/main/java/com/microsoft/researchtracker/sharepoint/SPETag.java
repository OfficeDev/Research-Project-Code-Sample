package com.microsoft.researchtracker.sharepoint;

public class SPETag {

    public static SPETag MATCH_ANY = new SPETag("*");

    private final String mValue;

    public SPETag(String value) {

        mValue = value;
    }

    public String getValue() {
        return mValue;
    }
}