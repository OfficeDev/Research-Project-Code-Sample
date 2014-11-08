using System;
using System.Linq;
using System.Net.Http;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.IdentityModel.Clients.ActiveDirectory;

namespace SpResearchTracker.Utils
{
    public class AccessTokenProvider
    {
        private readonly HttpRequestMessage _requestMessage;

        public AccessTokenProvider(HttpRequestMessage requestMessage)
        {
            if (requestMessage == null)
                throw new ArgumentNullException("requestMessage");

            _requestMessage = requestMessage;
        }

        /// <summary>
        /// Utilizes the OAuthController to get the access token for SharePoint
        /// in the name of the current user for the given tenancy.
        /// </summary>
        /// <returns>string containing the access token</returns>
        public async Task<string> GetAccessToken()
        {
            // Redeem the authorization code from the response for an access token and refresh token.
            var signInUserId = ClaimsPrincipal.Current.FindFirst(ClaimTypes.NameIdentifier).Value;
            var userObjectId = ClaimsPrincipal.Current.FindFirst("http://schemas.microsoft.com/identity/claims/objectidentifier").Value;
            var tenantId = ClaimsPrincipal.Current.FindFirst("http://schemas.microsoft.com/identity/claims/tenantid").Value;

            AuthenticationContext authContext = new AuthenticationContext(
                string.Format("{0}/{1}", AADAppSettings.AuthorizationUri, tenantId), 
                new SimpleDatabaseCache(signInUserId)
            );

            try
            {
                var result = await authContext.AcquireTokenSilentAsync(
                    AADAppSettings.Resource,
                    new ClientCredential(AADAppSettings.ClientId, AADAppSettings.AppKey),
                    new UserIdentifier(userObjectId, UserIdentifierType.UniqueId)
                    );

                return result.AccessToken;
            }
            catch (AdalException exception)
            {
                //handle token acquisition failure
                if (exception.ErrorCode == AdalError.FailedToAcquireTokenSilently)
                {
                    authContext.TokenCache.Clear();
                }
            }

            return null;
        }
    }
}