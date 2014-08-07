using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using WordResearchTrackerWeb.Controllers;

namespace WordResearchTrackerWeb.Models
{
    public interface IResearchRepository
    {
        Task<List<Project>> GetProjects();
        Task<List<Reference>> GetReferences();
    }
    /// <summary>
    /// The ResearchRepository is the core data access class
    /// </summary>
    public class ResearchRepository: IResearchRepository
    {
        public string ProjectsListName = ConfigurationManager.AppSettings["ProjectsListName"];
        public string ReferencesListName = ConfigurationManager.AppSettings["ReferencesListName"];
        public string SharePointResourceId = ConfigurationManager.AppSettings["ida:Resource"];
        public string SharePointServiceRoot = ConfigurationManager.AppSettings["ida:SiteUrl"];
        public string Tenant = ConfigurationManager.AppSettings["ida:Tenant"];

        /// <summary>
        /// Returns a collection of projects
        /// </summary>
        /// <returns>List</returns>
        public async Task<List<Project>> GetProjects()
        {
            List<Project> projects = new List<Project>();

            StringBuilder requestUri = new StringBuilder()
                .Append(this.SharePointServiceRoot)
                .Append("/_api/web/lists/getbyTitle('")
                .Append(this.ProjectsListName)
                .Append("')/items?$select=ID,Title");

            string accessToken = GetAccessToken();
            HttpResponseMessage response = await this.Get(requestUri.ToString(), accessToken);
            string responseString = await response.Content.ReadAsStringAsync();
            XElement root = XElement.Parse(responseString);

            foreach (XElement entryElem in root.Elements().Where(e => e.Name.LocalName == "entry"))
            {
                projects.Add(entryElem.ToProject());
            }

            return projects;
        }

        /// <summary>
        /// Returns a collection of references
        /// </summary>
        /// <returns>List</returns>
        public async Task<List<Reference>> GetReferences()
        {
            List<Reference> references = new List<Reference>();

            StringBuilder requestUri = new StringBuilder()
                .Append(this.SharePointServiceRoot)
                .Append("/_api/web/lists/getbyTitle('")
                .Append(this.ReferencesListName)
                .Append("')/items?$select=ID,Title,URL,Comments,Project");

            string accessToken = GetAccessToken();
            HttpResponseMessage response = await this.Get(requestUri.ToString(), accessToken);
            string responseString = await response.Content.ReadAsStringAsync();
            XElement root = XElement.Parse(responseString);

            foreach (XElement entryElem in root.Elements().Where(e => e.Name.LocalName == "entry"))
            {
                references.Add(entryElem.ToReference());
            }

            return references;
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
        private string GetAccessToken()
        {
            return OAuthController.GetAccessTokenFromCacheOrRefreshToken(this.Tenant, this.SharePointResourceId);
        }
    }
}