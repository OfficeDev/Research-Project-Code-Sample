Research Tracker Android Client
===============================

## Dependencies

-   [Android Studio][android-studio-download]
-   Android SDK Level 19 (install through [SDK Manager][sdk-manager])
-   Android Support Libraries (install through [SDK Manager][sdk-manager])

[android-studio-download]: https://developer.android.com/sdk/installing/studio.html
[sdk-manager]: http://developer.android.com/tools/help/sdk-manager.html

## Getting Started

1. Import `src/ResearchTracker` into Android Studio.
2. Open `src/ResearchTracker/app/src/main/java/com/microsoft/researchtracker/Constants.java`
3. Update the configuration:
    -   `SHAREPOINT_URL` -> Your O365 SharePoint URL (scheme + hostname), e.g. "https://mydomain.sharepoint.com"
    -   `SHAREPOINT_SITE_PATH` -> The path to the SharePoint site where you have the Research Tracker lists stored, e.g. "ContosoResearchTracker"
    -   `AAD_CLIENT_ID` -> The Client Id obtained for your App in Azure AD (in the form of a GUID)
    -   `AAD_REDIRECT_URL` -> The Client Redirect Url configured for your App in Azure AD, e.g. "http://example.com/redirect"
    -   `AAD_AUTHORITY` -> Use "https://login.windows.net/common"
4. Start the app in the emulator.