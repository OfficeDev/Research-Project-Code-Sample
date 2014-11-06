Research Tracker Android Client
===============================

## Dependencies

-   [Android Studio](https://developer.android.com/sdk/installing/studio.html)

## Getting Started

1. Import `src/ResearchTracker` into Android Studio.
2. Open `src/ResearchTracker/app/src/main/java/com/microsoft/researchtracker/Constants.java`
3. Update the configuration:
    -   `SHAREPOINT_URL` -> Your O365 SharePoint URL
    -   `SHAREPOINT_SITE_PATH` -> The path to the SharePoint site where you have
        the Research Tracker lists stored.
    -   `AAD_CLIENT_ID` -> The Client Id obtained for your App in Azure AD
    -   `AAD_REDIRECT_URL` -> The Client Redirect Url configured for your App in
        Azure AD
4. Start the app in the debugger.