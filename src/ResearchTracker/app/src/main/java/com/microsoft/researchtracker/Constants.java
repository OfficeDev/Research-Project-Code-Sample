package com.microsoft.researchtracker;

public final class Constants {

    public static final String SHAREPOINT_URL = "https://foxintergen.sharepoint.com";
    public static final String SHAREPOINT_SITE_PATH = "ContosoResearchTracker";

    public static final String EXCHANGE_RESOURCE_ID = "https://outlook.office365.com/";
    public static final String EXCHANGE_ODATA_ENDPOINT = "ews/odata";
    public static final int EXCHANGE_DEFAULT_MAX_RESULTS = 25;

    public static final String[] EXCHANGE_MAIL_FIELDS_TO_SELECT = { "Id", "Subject", "Sender", "ToRecipients", "CcRecipients", "DateTimeSent", "ToRecipients", "LastModifiedTime", "ParentFolderId" };
    public static final String[] EXCHANGE_CONTACT_FIELDS_TO_SELECT = { "Id", "DisplayName", "Surname", "EmailAddress1", "JobTitle", "Department", "CompanyName", "MiddleName", "GivenName", "NickName" };

    public static final String AAD_DOMAIN = "foxintergen.onmicrosoft.com";
    public static final String AAD_CLIENT_ID = "13b04d26-95fc-4fb4-a67e-c850e07822a8";
    public static final String AAD_AUTHORITY = "https://login.windows.net/common"; //"https://login.windows.net/" + AAD_DOMAIN;
    public static final String AAD_REDIRECT_URL = "http://android/complete";

    public static final String AAD_RESOURCE_ID = SHAREPOINT_URL; //EXCHANGE_RESOURCE_ID;

    public static final String RESEARCH_PROJECTS_LIST = "Research Projects";
    public static final String RESEARCH_REFERENCES_LIST = "Research References";
}
