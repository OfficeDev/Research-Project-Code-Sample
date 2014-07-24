using Microsoft.Office365.OAuth;
using OutlookResearchTrackerWeb.Models;
using System;
using System.Configuration;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace OutlookResearchTrackerWeb.Controllers
{
    public class HomeController : Controller
    {
        private IResearchRepository _repository;

        public HomeController(IResearchRepository repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// This action is called when the App is first loaded.
        /// It initiates the process of getting an access token for SharePoint.
        /// Note that it supports using either the O365 APIs or a special OAuth Controller.
        /// The O365 APIs have more abstraction and offer simpler coding.
        /// The OAuth controller provides more flexibility, but has more code.
        /// </summary>
        /// <returns>RedirectResult</returns>
        [HttpGet]
        public async Task<ActionResult> Index(string authType)
        {
            string resource = ConfigurationManager.AppSettings["ida:resource"];

            if (authType == "O365")
            {
                Authenticator authenticator = new Authenticator();
                var authInfo = await authenticator.AuthenticateAsync(resource, ServiceIdentifierKind.Resource);
                string accessToken = await authInfo.GetAccessToken();
                OAuthController.SaveAccessTokenInCache(resource, accessToken, DateTime.Now.AddMinutes(10).ToString());
                return new RedirectResult("/Home/App");

            }
            else
            {
                string redirectUri = this.Request.Url.GetLeftPart(UriPartial.Authority).ToString() + "/Home/App";
                string authorizationUrl = OAuthController.GetAuthorizationUrl(resource, new Uri(redirectUri));
                return new RedirectResult(authorizationUrl);
            }
        }

        /// <summary>
        /// This action creates a view model with a collection of projects and references
        /// It is the main page of the app
        /// </summary>
        /// <param name="projectName"></param>
        /// <returns>ActionResult(ViewModel)</returns>
        /// [HttpGet]
        public async Task<ActionResult> App(string projectName)
        {
            ViewModel viewModel = new ViewModel();
            viewModel.SelectedProject = projectName == null ? "Select..." : projectName;
            viewModel.Projects = await _repository.GetProjects();
            viewModel.Projects.Insert(0, new Project() { Title = "Select...", Id = -1, eTag = string.Empty, Type = string.Empty });
            viewModel.References = await _repository.GetReferences();
            viewModel.ProjectEntityType = await _repository.GetProjectEntityType();
            viewModel.ReferenceEntityType = await _repository.GetReferenceEntityType();
            return View(viewModel);
        }

        [HttpPost]
        public async Task<ActionResult> App(string projectName, string referenceLink, string referenceEntityType)
        {
            if (projectName != "Select..." && referenceLink != "Select...")
            {
                Reference reference = new Reference()
                {
                    Title = string.Empty,
                    Type = referenceEntityType,
                    eTag = "0",
                    Id = 0,
                    Notes = "Created by Outlook",
                    Project = projectName,
                    Url = referenceLink
                };
                Reference newReference = await _repository.CreateReference(reference);
            }
            return RedirectToAction("App", new { projectName = projectName });
        }
    }
}