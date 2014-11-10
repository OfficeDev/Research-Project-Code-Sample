using System;
using System.Diagnostics;
using System.IdentityModel.Claims;
using System.Threading.Tasks;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Owin.Security;
using Microsoft.Owin.Security.Cookies;
using Microsoft.Owin.Security.OpenIdConnect;
using OutlookResearchTrackerWeb.Utils;
using Owin;

namespace OutlookResearchTrackerWeb
{
    public partial class Startup
    {
        public void ConfigureAuth(IAppBuilder app)
        {
            app.SetDefaultSignInAsAuthenticationType(CookieAuthenticationDefaults.AuthenticationType);

            app.UseCookieAuthentication(new CookieAuthenticationOptions());

            app.UseOpenIdConnectAuthentication(
                new OpenIdConnectAuthenticationOptions {

                    ClientId = AADAppSettings.ClientId,
                    Authority = AADAppSettings.Authority,

                    TokenValidationParameters = new System.IdentityModel.Tokens.TokenValidationParameters {
                        // instead of using the default validation (validating against a single issuer value, as we do in line of business apps (single tenant apps)), 
                        // we turn off validation
                        //
                        // NOTE:
                        // * In a multitenant scenario you can never validate against a fixed issuer string, as every tenant will send a different one.
                        // * If you don’t care about validating tenants, as is the case for apps giving access to 1st party resources, you just turn off validation.
                        // * If you do care about validating tenants, think of the case in which your app sells access to premium content and you want to limit access only to the tenant that paid a fee, 
                        //       you still need to turn off the default validation but you do need to add logic that compares the incoming issuer to a list of tenants that paid you, 
                        //       and block access if that’s not the case.
                        // * Refer to the following sample for a custom validation logic: https://github.com/AzureADSamples/WebApp-WebAPI-MultiTenant-OpenIdConnect-DotNet

                        ValidateIssuer = false
                    },

                    Notifications = new OpenIdConnectAuthenticationNotifications {
                        // If there is a code in the OpenID Connect response, redeem it for an access token and refresh token, and store those away. 
                        AuthorizationCodeReceived = async context => {

                            var serviceCredential = new ClientCredential(AADAppSettings.ClientId, AADAppSettings.AppKey);

                            string tenantID = context.AuthenticationTicket.Identity.FindFirst("http://schemas.microsoft.com/identity/claims/tenantid").Value;
                            string nameIdentifier = context.AuthenticationTicket.Identity.FindFirst(ClaimTypes.NameIdentifier).Value;

                            AuthenticationContext authContext = new AuthenticationContext(
                                string.Format("{0}/{1}", AADAppSettings.AuthorizationUri, tenantID),
                                new SimpleTokenCache(nameIdentifier)
                            );

                            // Get the access token for AAD Graph. Doing this will also initialize the token cache associated with the authentication context
                            // In theory, you could acquire token for any service your application has access to here so that you can initialize the token cache
                            AuthenticationResult result = await authContext.AcquireTokenByAuthorizationCodeAsync(
                                context.Code,
                                new Uri(context.Request.Uri.GetLeftPart(UriPartial.Path)),
                                serviceCredential,
                                AADAppSettings.SharePointResourceId
                            );

                            Debug.WriteLine("Auth result: {0}", result);
                        },

                        RedirectToIdentityProvider = (context) => {
                            // This ensures that the address used for sign in and sign out is picked up dynamically from the request
                            // this allows you to deploy your app (to Azure Web Sites, for example)without having to change settings
                            // Remember that the base URL of the address used here must be provisioned in Azure AD beforehand.
                            string appBaseUrl = context.Request.Scheme + "://" + context.Request.Host + context.Request.PathBase;
                            context.ProtocolMessage.RedirectUri = appBaseUrl + "/Home/App";
                            context.ProtocolMessage.PostLogoutRedirectUri = appBaseUrl;

                            return Task.FromResult(0);
                        },

                        AuthenticationFailed = (context) => {
                            // Suppress the exception
                            context.HandleResponse();

                            return Task.FromResult(0);
                        }
                    }

                });
        }
    }
}