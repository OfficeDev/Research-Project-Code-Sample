using System.Security.Claims;
using System.Web;
using System.Web.Mvc;
using Microsoft.Owin.Security;
using Microsoft.Owin.Security.Cookies;
using Microsoft.Owin.Security.OpenIdConnect;
using OutlookResearchTrackerWeb.Utils;

namespace WordResearchTrackerWeb.Controllers
{
    public class AccountController : Controller
    {
        public void SignIn()
        {
            var homeAppUrl = Url.Action("App", "Home", null, Request.Url.Scheme);

            HttpContext.GetOwinContext().Authentication.Challenge(new AuthenticationProperties { RedirectUri = homeAppUrl }, OpenIdConnectAuthenticationDefaults.AuthenticationType);
        }

        public void SignOut()
        {
            // Remove all cache entries for this user and send an OpenID Connect sign-out request.
            if (!Request.IsAuthenticated)
            {
                var homeIndexUrl = Url.Action("Index", "Home", null, Request.Url.Scheme);

                Response.Redirect(homeIndexUrl);
            }
            else
            {
                string nameIdentifier = ClaimsPrincipal.Current.FindFirst(ClaimTypes.NameIdentifier).Value;

                new SimpleTokenCache(nameIdentifier).Clear();

                HttpContext.GetOwinContext().Authentication.SignOut(
                    OpenIdConnectAuthenticationDefaults.AuthenticationType,
                    CookieAuthenticationDefaults.AuthenticationType
                );
            }
        }
    }
}
