using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;

namespace SpResearchTracker.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            //The application is configured to authenticate against O365
            //Then another round trip is made to get an access token for SharePoint
            string resource = ConfigurationManager.AppSettings["ida:Resource"];
            string redirectUri = this.Request.Url.GetLeftPart(UriPartial.Authority).ToString() + "/Home/SPA";
            string authorizationUrl = OAuthController.GetAuthorizationUrl(resource, new Uri(redirectUri));
            return new RedirectResult(authorizationUrl);
        }

        public ActionResult SPA()
        {
            //This method just returns the view where the SPA is located
            return View();
        }
    }
}