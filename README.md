Microsoft SharePoint 2013 Cloud App Model Reference Implementation
===========

This repository contains three (3) reference implementation applications demonstrating the SharePoint Cloud App Model. All samples are designed to work with Microsoft Azure & Office 365, not an on-premises SharePoint 2013 deployment. The applications all reside outside of SharePoint & Office 365.

A presentation on all samples can be found in the [presentation folder](presentation) within this repository.

![](/images/channel9scrnsht.png)

An on-demand web cast recorded by Andrew Connell can be found on [Channel 9](http://channel9.msdn.com/Blogs/Office-365-Dev/Getting-started-with-the-Research-Project-Tracker-AngularJS-Office-365-API-Code-Sample).

##Sample Applications
The three sample applications can all be found within the [src](src) folder. Each app has mandatory setup steps in both Microsoft Azure & within the `web.config` within the project. The projects within in the Visual Studio solution are as follows:

### Web App - Single Page Application (SPA)
![](/images/spascrnsht.png)

The Web App is the primary way to interact with the Project Reference Tracker. It is implemented as an ASP.NET MVC5, WebAPI for the backend & single page app (SPA) for the front end experience. The user can create, edit, delete and view projects & references that are stored in SharePoint lists.

**Visual Studio Project(s):**
- **[SpResearchTracker](/src/SpResearchTracker)**

You will find setup instructions within the **[README.md](/src/SpResearchTracker/README.md)** file in the **[SpResearchTracker](/src/SpResearchTracker)** project.

-----------------

### Office Outlook App
![](/images/outlookscrnsht.png)

The Outlook App installs in the Outlook Web App and automatically activates when it detects a URL within the selected email. The user can then select an exiting project and the link(s) it wants to add to the project.

**Visual Studio Project(s):**
- **[OutlookResearchTracker](/src/OutlookResearchTracker)**: Office Outlook App Addin
- **[OutlookResearchTrackerWeb](/src/OutlookResearchTrackerWeb)**: Backend WebAPI intermediary application used to talk to Office 365 & SharePoint Online for the addin.

You will find setup instructions within the **[README.md](/src/OutlookResearchTracker/README.md)** file in the **[OutlookResearchTracker](/src/OutlookResearchTracker)** project.

-----------------

### Office Word App
![](/images/wordscrnsht.png)

The Word App installs in the Office Word desktop App as a new task pane. Once the user logs in, they can select an existing project and one or more references to add as a table to the current Word document.

**Visual Studio Project(s):**
- **[WordResearchTracker](/src/WordResearchTracker)**: Office Word App Addin
- **[WordResearchTrackerWeb](/src/WordResearchTrackerWeb)**: Backend WebAPI intermediary application used to talk to Office 365 & SharePoint Online for the addin.

You will find setup instructions within the **[README.md](/src/WordResearchTracker/README.md)** file in the **[WordResearchTracker](/src/WordResearchTracker)** project.

-----------------

##Special Note on Creating the Azure Applications
The three reference samples in this repository are intended to use their own Azure application... this includes the setup instructions for each sample. This is how you would likely implement the samples in production so we wanted to keep it as real world as possible.

However it's understood that many of these samples will be used simply as a learning tool. Thus, creating a separate Azure application for each sample may seem tedious. There is no technical reason why the samples couldn't share the same Azure application. You just need to make sure that the redirect URL's you enter in the Azure application are present for all the samples if you elect to use the same Azure application for all samples.
