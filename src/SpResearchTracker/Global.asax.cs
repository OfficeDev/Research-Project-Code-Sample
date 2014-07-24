using System;
using System.Collections.Generic;
using System.IdentityModel.Services;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using System.Web.Http;
using System.Web.Routing;
using System.Web.SessionState;

namespace SpResearchTracker
{
    public class MvcApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            GlobalConfiguration.Configure(WebApiConfig.Register); 
            AreaRegistration.RegisterAllAreas();
            IdentityConfig.ConfigureIdentity();
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
        }

        private void WSFederationAuthenticationModule_RedirectingToIdentityProvider(object sender, RedirectingToIdentityProviderEventArgs e)
        {
            if (!String.IsNullOrEmpty(IdentityConfig.Realm))
            {
                e.SignInRequestMessage.Realm = IdentityConfig.Realm;
            }
        }

        /// <summary>
        /// Enabled session state for storing the access token
        /// </summary>
        protected void Application_PostAuthorizeRequest()
        {
            if (HttpContext.Current.Request.AppRelativeCurrentExecutionFilePath.StartsWith("~/odata") ||
                HttpContext.Current.Request.AppRelativeCurrentExecutionFilePath.StartsWith("~/api"))
            {
                HttpContext.Current.SetSessionStateBehavior(SessionStateBehavior.Required);
            }
        }

    }
}
