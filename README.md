Research Tracker iOS Client
===========================

## Dependencies

-   [Xcode][xcode-app-store]
-   [Cocoapods][cocoapods-home]

[xcode-app-store]: https://itunes.apple.com/nz/app/xcode/id497799835?mt=12
[cocoapods-home]: http://cocoapods.org/


## Getting started

1.  Launch Terminal and navigate to the `src` directory

2.  Install the Cocoapods dependencies with the following command

	```bash
    $ pod install
    ```

3.  This command has update your `.xcworkspace` file. From now on, use
    this file to open the Xcode project.

    ```bash
    $ open ResearchProjectTrackerApp.xcworkspace
	```

4.  Open the `Supporting Files/Auth.plist` configuration file and fill out
    the following values:

    -   `resourceId` -> Your O365 SharePoint URL (scheme + hostname), e.g. "https://mydomain.sharepoint.com"
    -   `o365SharepointTenantUrl` -> Your O365 SharePoint URL and Site path, e.g. "https://mydomain.sharepoing.com/ContosoResearchTracker"
    -   `redurectUriString` -> The Client Redirect Url configured for your App in Azure AD, e.g. "http://example.com/redirect"
    -   `clientId` -> The Client Id obtained for your App in Azure AD (in the form of a GUID)
    -   `authority` -> Use "https://login.windows.net/common"

5.  Use **Product > Run** to start the app in the emulator

6.  Sign in using a user from your O365 Tenant
