using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using SpResearchTracker.Utils;

namespace SpResearchTracker.Models
{
    public class AccessTokenProvider
    {
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
                new NaiveSessionCache(signInUserId)
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
                return null;
            }
        }
    }
}