using System;
using OutlookResearchTrackerWeb.Utils;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Text;
using System.Configuration;
using System.Xml.Linq;
using System.Text.RegularExpressions;

namespace OutlookResearchTrackerWeb.Models
{
    /// <summary>
    /// The repository interface
    /// </summary>
    public interface IResearchRepository
    {
        Task<List<Project>> GetProjects();
        Task<List<Reference>> GetReferences(string projectId);
        Task<Reference> CreateReference(Reference reference);
        Task<string> GetProjectEntityType();
        Task<string> GetReferenceEntityType();
    }

    /// <summary>
    /// The Research Repository is the core data access class
    /// </summary>
    public class ResearchRepository : IResearchRepository
    {
        public static readonly string ProjectsListName = ConfigurationManager.AppSettings["ProjectsListName"];
        public static readonly string ReferencesListName = ConfigurationManager.AppSettings["ReferencesListName"];
        public static readonly string SiteUrl = ConfigurationManager.AppSettings["ida:SiteUrl"];

        private Task<string> GetAccessTokenAsync()
        {
            return new TokenProvider().GetSharePointAccessToken();
        }

        /// <summary>
        /// Returns a collection of projects
        /// </summary>
        /// <returns>List</returns>
        public async Task<List<Project>> GetProjects()
        {
            StringBuilder requestUri = new StringBuilder()
                .Append(SiteUrl)
                .Append("/_api/web/lists/getbyTitle('")
                .Append(ProjectsListName)
                .Append("')/items?$select=ID,Title&$orderby=Title");

            HttpResponseMessage response = await Get(requestUri.ToString(), await GetAccessTokenAsync());
            string responseString = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception("Error Retrieving Projects: " + responseString);
            }

            XElement root = XElement.Parse(responseString);

            return root.Elements()
                       .Where(e => e.Name.LocalName == "entry")
                       .Select(e => e.ToProject())
                       .ToList();
        }

        /// <summary>
        /// Returns a collection of References
        /// </summary>
        /// <param name="projectId"></param>
        /// <returns>List</returns>
        public async Task<List<Reference>> GetReferences(string projectId)
        {
            StringBuilder requestUri = new StringBuilder()
                .Append(SiteUrl)
                .Append("/_api/web/lists/getbyTitle('")
                .Append(ReferencesListName)
                .AppendFormat("')/items?$filter=Project eq '{0}'&select=ID,Title,URL,Comments,Project", projectId);

            HttpResponseMessage response = await Get(requestUri.ToString(), await GetAccessTokenAsync());
            string responseString = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception("Error Retrieving References: " + responseString);
            }

            XElement root = XElement.Parse(responseString);

            return root.Elements()
                       .Where(e => e.Name.LocalName == "entry")
                       .Select(entryElem => entryElem.ToReference())
                       .ToList();

        }

        public Task<string> GetProjectEntityType()
        {
            return GetListEntityType(ProjectsListName);
        }

        public Task<string> GetReferenceEntityType()
        {
            return GetListEntityType(ReferencesListName);
        }

        /// <summary>
        /// Retrieves the entity type for the SharePoint list item
        /// </summary>
        /// <returns>Entity type name</returns>
        private async Task<string> GetListEntityType(string ListName)
        {
            StringBuilder requestUri = new StringBuilder()
                .Append(SiteUrl)
                .Append("/_api/web/lists/getbyTitle('")
                .Append(ListName)
                .Append("')");

            HttpResponseMessage response = await Get(requestUri.ToString(), await GetAccessTokenAsync());
            string responseString = await response.Content.ReadAsStringAsync();
            if (!response.IsSuccessStatusCode)
            {
                throw new Exception("Error Retrieving ListEntityType: " + responseString);
            }
            XElement root = XElement.Parse(responseString);
            return root.Descendants(ExtensionMethods.d + "ListItemEntityTypeFullName").First().Value;
        }

        /// <summary>
        /// Adds a new reference based on links in the e-mail message body
        /// </summary>
        /// <param name="reference"></param>
        /// <returns>Reference</returns>
        public async Task<Reference> CreateReference(Reference reference)
        {
            StringBuilder requestUri = new StringBuilder()
                 .Append(SiteUrl)
                 .Append("/_api/web/lists/getbyTitle('")
                 .Append(ReferencesListName)
                 .Append("')/items");

            if (string.IsNullOrEmpty(reference.Title))
            {
                reference.Title = await GetTitleFromLink(reference.Url);
            }

            XElement entry = reference.ToXElement();

            StringContent requestContent = new StringContent(entry.ToString());
            HttpResponseMessage response = await Post(requestUri.ToString(), await GetAccessTokenAsync(), requestContent);
            string responseString = await response.Content.ReadAsStringAsync();
            if (!response.IsSuccessStatusCode)
            {
                throw new Exception("Error Creating reference: " + responseString);
            }
            return XElement.Parse(responseString).ToReference();

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
            if (eTag.Length > 0)
            {
                request.Headers.IfNoneMatch.Add(new EntityTagHeaderValue("\"" + eTag + "\""));
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
            requestData.Headers.ContentType = MediaTypeHeaderValue.Parse("application/atom+xml");
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
            requestData.Headers.ContentType = MediaTypeHeaderValue.Parse("application/atom+xml");
            request.Headers.IfMatch.Add(new EntityTagHeaderValue("\"" + eTag + "\""));
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
            if (eTag.Length == 0)
            {
                eTag = "*";
            }
            request.Headers.IfMatch.Add(new EntityTagHeaderValue("\"" + eTag + "\""));

            return await client.SendAsync(request);
        }

        /// <summary>
        /// Get the title for a link by downloading the referenced page 
        /// </summary>
        /// <param name="Url">The URL of the reference</param>
        /// <returns>Title of the page</returns>
        private async Task<string> GetTitleFromLink(string Url)
        {
            HttpClient client = new HttpClient();
            HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Get, Url);
            HttpResponseMessage response = await client.SendAsync(request);
            string responseString = await response.Content.ReadAsStringAsync();
            Match match = Regex.Match(responseString, @"<title>\s*(.+?)\s*</title>");
            if (match.Success)
            {
                return match.Groups[1].Value;
            }

            return "Unknown Title";
        }
    }
}