using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using OutlookResearchTrackerWeb.Utils;

namespace WordResearchTrackerWeb.Models
{
    public interface IResearchRepository
    {
        Task<List<Project>> GetProjects();
        Task<List<Reference>> GetReferences(string projectName);
    }
    /// <summary>
    /// The ResearchRepository is the core data access class
    /// </summary>
    public class ResearchRepository: IResearchRepository
    {
        public static readonly string SharePointServiceRoot = ConfigurationManager.AppSettings["ida:SiteUrl"];
        public static readonly string ProjectsListName = ConfigurationManager.AppSettings["ProjectsListName"];
        public static readonly string ReferencesListName = ConfigurationManager.AppSettings["ReferencesListName"];

        /// <summary>
        /// Returns a collection of projects
        /// </summary>
        /// <returns>List</returns>
        public async Task<List<Project>> GetProjects()
        {
            StringBuilder requestUri = new StringBuilder()
                .Append(SharePointServiceRoot)
                .Append("/_api/web/lists/getbyTitle('")
                .Append(ProjectsListName)
                .Append("')/items?$select=ID,Title");

            HttpResponseMessage response = await this.Get(requestUri.ToString(), await GetAccessToken());
            string responseString = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception("Error retrieving projects: " + responseString);
            }
            
            XElement root = XElement.Parse(responseString);

            return root.Elements()
                       .Where(e => e.Name.LocalName == "entry")
                       .Select(entryElem => entryElem.ToProject())
                       .ToList();
        }

        /// <summary>
        /// Returns a collection of references
        /// </summary>
        /// <param name="projectName"></param>
        /// <returns>List</returns>
        public async Task<List<Reference>> GetReferences(string projectName)
        {
            StringBuilder requestUri = new StringBuilder()
                .Append(SharePointServiceRoot)
                .Append("/_api/web/lists/getbyTitle('")
                .Append(ReferencesListName)
                .AppendFormat("')/items?$filter=Project eq '{0}'&$select=ID,Title,URL,Comments,Project", projectName);

            HttpResponseMessage response = await this.Get(requestUri.ToString(), await GetAccessToken());
            string responseString = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception("Error retrieving references: " + responseString);
            }

            XElement root = XElement.Parse(responseString);

            return root.Elements()
                       .Where(e => e.Name.LocalName == "entry")
                       .Select(entryElem => entryElem.ToReference())
                       .ToList();
        }

        private async Task<HttpResponseMessage> Get(string requestUri, string accessToken)
        {
            HttpClient client = new HttpClient();
            HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Get, requestUri);
            request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/xml"));
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
            return await client.SendAsync(request);
        }

        /// <summary>
        /// Retrieves an access token from the OAuth Controller
        /// </summary>
        /// <returns>Access Token</returns>
        private Task<string> GetAccessToken()
        {
            return new TokenProvider().GetSharePointAccessToken();
        }
    }
}