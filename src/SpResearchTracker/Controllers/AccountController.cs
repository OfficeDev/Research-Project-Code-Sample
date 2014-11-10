using Microsoft.Owin.Security;
using Microsoft.Owin.Security.Cookies;
using Microsoft.Owin.Security.OpenIdConnect;
using SpResearchTracker.Utils;
using System.Security.Claims;
using System.Web;
using System.Web.Mvc;

namespace SpResearchTracker.Controllers
{
    public class AccountController : Controller
    {
        private string GetHomeIndexUrl()
        {
            return Url.Action("SPA", "Home", null, Request.Url.Scheme);
        }

        public void SignIn()
        {
            var homeIndex = GetHomeIndexUrl();

            if (!Request.IsAuthenticated)
            {
                HttpContext.GetOwinContext().Authentication.Challenge(new AuthenticationProperties { RedirectUri = homeIndex }, OpenIdConnectAuthenticationDefaults.AuthenticationType);
            }
            else
            {
                Response.Redirect(homeIndex);
            }
        }

        public void SignOut()
        {
            // Remove all cache entries for this user and send an OpenID Connect sign-out request.
            if (!Request.IsAuthenticated)
            {
                var homeIndex = GetHomeIndexUrl();

                Response.Redirect(homeIndex);
            }
            else
            {
                string nameIdentifier = ClaimsPrincipal.Current.FindFirst(ClaimTypes.NameIdentifier).Value;

                new SimpleDatabaseTokenCache(nameIdentifier).Clear();

                HttpContext.GetOwinContext().Authentication.SignOut(
                    OpenIdConnectAuthenticationDefaults.AuthenticationType,
                    CookieAuthenticationDefaults.AuthenticationType
                );
            }
        }
    }
}
