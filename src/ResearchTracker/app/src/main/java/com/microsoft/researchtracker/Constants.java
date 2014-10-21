package com.microsoft.researchtracker;

public final class Constants {

    public static final String SHAREPOINT_URL = "https://foxintergenusa.sharepoint.com";
    public static final String SHAREPOINT_SITE_PATH = "ContosoResearchTracker";

    public static final String AAD_DOMAIN = "foxintergenusa.onmicrosoft.com";
    public static final String AAD_CLIENT_ID = "3a164325-14ba-471b-beb8-7b40a9f1a72e";
    public static final String AAD_AUTHORITY = "https://login.windows.net/common"; //"https://login.windows.net/" + AAD_DOMAIN;
    public static final String AAD_REDIRECT_URL = "http://example.com/redirect";

    public static final String AAD_RESOURCE_ID = SHAREPOINT_URL; //EXCHANGE_RESOURCE_ID;

    public static final String RESEARCH_PROJECTS_LIST = "Research Projects";
    public static final String RESEARCH_REFERENCES_LIST = "Research References";
}
