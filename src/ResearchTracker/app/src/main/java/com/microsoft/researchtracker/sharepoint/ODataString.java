package com.microsoft.researchtracker.sharepoint;

public class ODataString {

    public static final String SINGLE_QUOTE = "\'";

    private String mValue;

    public ODataString(final String value) {
        mValue = value;
    }

    @Override
    public String toString() {
        return SINGLE_QUOTE + mValue.replace(SINGLE_QUOTE, "''") + SINGLE_QUOTE;
    }
}
