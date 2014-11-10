using Microsoft.Owin.Security;
using Microsoft.Owin.Security.Cookies;
using Microsoft.Owin.Security.OpenIdConnect;
using SpResearchTracker.Utils;
using System;
using System.Security.Claims;
using System.Web;
using System.Web.Mvc;

namespace SpResearchTracker.Controllers
{
    public class AccountController : Controller
    {
        public void SignIn()
        {
            string homeIndex = Url.Action("SPA", "Home", null, Request.Url.Scheme);

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
                SignIn();
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

        public ActionResult ConsentApp()
        {
            string strResource = Request.QueryString["resource"];
            string strRedirectController = Request.QueryString["redirect"];

            string authorizationRequest = String.Format(
                "https://login.windows.net/common/oauth2/authorize?response_type=code&client_id={0}&resource={1}&redirect_uri={2}",
                Uri.EscapeDataString(AADAppSettings.ClientId),
                Uri.EscapeDataString(strResource),
                Uri.EscapeDataString(String.Format("{0}/{1}", this.Request.Url.GetLeftPart(UriPartial.Authority), strRedirectController))
            );

            return new RedirectResult(authorizationRequest);
        }

        public ActionResult AdminConsentApp()
        {
            string strResource = Request.QueryString["resource"];
            string strRedirectController = Request.QueryString["redirect"];

            string authorizationRequest = String.Format(
                "https://login.windows.net/common/oauth2/authorize?response_type=code&client_id={0}&resource={1}&redirect_uri={2}&prompt={3}",
                    Uri.EscapeDataString(AADAppSettings.ClientId),
                    Uri.EscapeDataString(strResource),
                    Uri.EscapeDataString(String.Format("{0}/{1}", this.Request.Url.GetLeftPart(UriPartial.Authority).ToString(), strRedirectController)),
                    Uri.EscapeDataString("admin_consent")
                    );

            return new RedirectResult(authorizationRequest);
        }

        public void RefreshSession()
        {
            string strRedirectController = Request.QueryString["redirect"];

            HttpContext.GetOwinContext().Authentication.Challenge(new AuthenticationProperties { RedirectUri = String.Format("/{0}", strRedirectController) }, OpenIdConnectAuthenticationDefaults.AuthenticationType);
        }
    }
}
