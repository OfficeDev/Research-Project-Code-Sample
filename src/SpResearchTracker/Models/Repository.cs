using SpResearchTracker.Controllers;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Xml.Linq;
using SpResearchTracker.Utils;
using System.Web.Helpers;

namespace SpResearchTracker.Models
{
    public abstract class Repository
    {
        public string ProjectsListName = ConfigurationManager.AppSettings["ProjectsListName"];
        public string ReferencesListName = ConfigurationManager.AppSettings["ReferencesListName"];
        public string SiteUrl = ConfigurationManager.AppSettings["ida:SiteUrl"];
        public string Resource = ConfigurationManager.AppSettings["ida:Resource"];
        public string Tenant = ConfigurationManager.AppSettings["ida:Tenant"];

        /// <summary>
        /// Utilizes the OAuthController to get the access token for SharePoint
        /// in the name of the current user for the given tenancy.
        /// </summary>
        /// <returns>string containing the access token</returns>
        public string GetAccessToken()
        {
            string accessToken = OAuthController.GetAccessTokenFromCacheOrRefreshToken(this.Tenant, this.Resource);
            return accessToken;

        }

        /// <summary>
        /// Implements common GET functionality
        /// </summary>
        /// <param name="requestUri">The REST endpoint</param>
        /// <param name="accessToken">The SharePoint access token</param>
        /// <returns>XElement with results of operation</returns>
        public async Task<HttpResponseMessage> Get(string requestUri, string accessToken, string eTag)
        {
            HttpClient client = new HttpClient();
            HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Get, requestUri);
            request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/xml"));
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
            if (eTag.Length > 0 && eTag != "*")
            {
                request.Headers.IfNoneMatch.Add(new EntityTagHeaderValue(eTag));
            }
            return await client.SendAsync(request);
        }

        public async Task<HttpResponseMessage> Get(string requestUri, string accessToken)
        {
            return await this.Get(requestUri, accessToken, string.Empty);
        }

        /// <summary>
        /// Implements common POST functionality
        /// </summary>
        /// <param name="requestUri">The REST endpoint</param>
        /// <param name="accessToken">The SharePoint access token</param>
        /// <param name="requestData">The POST data</param>
        /// <returns>XElement with results of operation</returns>
        public async Task<HttpResponseMessage> Post(string requestUri, string accessToken, StringContent requestData)
        {
            HttpClient client = new HttpClient();
            HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, requestUri);
            request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/xml"));
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
            requestData.Headers.ContentType = System.Net.Http.Headers.MediaTypeHeaderValue.Parse("application/atom+xml");
            request.Content = requestData;
            return await client.SendAsync(request);
        }

        /// <summary>
        /// Implements common PATCH functionality
        /// </summary>
        /// <param name="requestUri">The REST endpoint</param>
        /// <param name="accessToken">The SharePoint access token</param>
        /// <param name="eTag">The eTag of the item</param>
        /// <param name="requestData">The data to use during the update</param>
        /// <returns>XElement with results of operation</returns>
        public async Task<HttpResponseMessage> Patch(string requestUri, string accessToken, string eTag, StringContent requestData)
        {
            HttpClient client = new HttpClient();
            HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, requestUri);
            request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/xml"));
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
            requestData.Headers.ContentType = System.Net.Http.Headers.MediaTypeHeaderValue.Parse("application/atom+xml");
            if (eTag == "*")
            {
                request.Headers.Add("IF-MATCH", "*");
            }
            else
            {
                request.Headers.IfMatch.Add(new EntityTagHeaderValue(eTag));
            }
            request.Headers.Add("X-Http-Method", "PATCH");
            request.Content = requestData;
            return await client.SendAsync(request);
        }

        /// <summary>
        /// Implements common DELETE functionality
        /// </summary>
        /// <param name="requestUri">The REST endpoint</param>
        /// <param name="accessToken">The SharePoint access token</param>
        /// <param name="eTag">The eTag of the item</param>
        /// <returns>XElement with results of operation</returns>
        public async Task<HttpResponseMessage> Delete(string requestUri, string accessToken, string eTag)
        {
            HttpClient client = new HttpClient();
            HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Delete, requestUri);
            request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/xml"));
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
            if (eTag == "*")
            {
                request.Headers.Add("IF-MATCH", "*");
            }
            else
            {
                request.Headers.IfMatch.Add(new EntityTagHeaderValue(eTag));
            }

            return await client.SendAsync(request);
        }
    }
}