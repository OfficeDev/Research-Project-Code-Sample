using Microsoft.Office365.OAuth;
using Microsoft.Office365.SharePoint;
using System;
using System.Configuration;
using System.Threading.Tasks;
using System.Web.Mvc;
using WordResearchTrackerWeb.Models;

namespace WordResearchTrackerWeb.Controllers
{
    public class HomeController : Controller
    {
        static readonly string ServiceResourceId = ConfigurationManager.AppSettings["ida:resource"];
        static readonly Uri ServiceEndpointUri = new Uri(ConfigurationManager.AppSettings["ida:SiteURL"] + "/_api/");

        // Do not make static in Web apps; store it in session or in a cookie instead
        static string _lastLoggedInUser;
        static DiscoveryContext _discoveryContext;

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
            if (authType == "O365")
            {
                try
                {
                    if (_discoveryContext == null)
                    {
                        _discoveryContext = await DiscoveryContext.CreateAsync();
                    }
                    var dcr = await _discoveryContext.DiscoverResourceAsync(ServiceResourceId);
                    _lastLoggedInUser = dcr.UserId;
                    string accessToken = (await _discoveryContext.AuthenticationContext.AcquireTokenByRefreshTokenAsync(new SessionCache().Read("RefreshToken"), new Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential(_discoveryContext.AppIdentity.ClientId, _discoveryContext.AppIdentity.ClientSecret), ServiceResourceId)).AccessToken;

                    OAuthController.SaveAccessTokenInCache(ServiceResourceId, accessToken, DateTime.Now.AddMinutes(10).ToString());
                    return new RedirectResult("/Home/App");
                }
                catch (RedirectRequiredException ex)
                {
                    return Redirect(ex.RedirectUri.ToString());
                }

            }
            else
            {
                string redirectUri = this.Request.Url.GetLeftPart(UriPartial.Authority).ToString() + "/Home/App";
                string authorizationUrl = OAuthController.GetAuthorizationUrl(ServiceResourceId, new Uri(redirectUri));
                return new RedirectResult(authorizationUrl);
            }
        }

        [HttpGet]
        public async Task<ActionResult> O365API()
        {
            if (_discoveryContext == null)
            {
                _discoveryContext = await DiscoveryContext.CreateAsync();
            }
            var dcr = await _discoveryContext.DiscoverResourceAsync(ServiceResourceId);
            _lastLoggedInUser = dcr.UserId;
            string accessToken = (await _discoveryContext.AuthenticationContext.AcquireTokenByRefreshTokenAsync(new SessionCache().Read("RefreshToken"), new Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential(_discoveryContext.AppIdentity.ClientId, _discoveryContext.AppIdentity.ClientSecret), ServiceResourceId)).AccessToken;

            OAuthController.SaveAccessTokenInCache(ServiceResourceId, accessToken, DateTime.Now.AddMinutes(10).ToString());
            return new RedirectResult("/Home/App");
        }

        /// <summary>
        /// This action creates a view model with a collection of projects and references
        /// It is the main page of the app
        /// </summary>
        /// <param name="projectName"></param>
        /// <returns>ActionResult(ViewModel)</returns>
        [HttpGet]
        public async Task<ActionResult> App(string projectName)
        {
            ViewModel viewModel = new ViewModel();
            viewModel.SelectedProject = projectName == null ? "Select..." : projectName;
            viewModel.Projects = await _repository.GetProjects();
            viewModel.Projects.Insert(0, new Project() { Title = "Select...", Id = -1 });
            viewModel.References = await _repository.GetReferences();
            return View(viewModel);
        }

    }
}