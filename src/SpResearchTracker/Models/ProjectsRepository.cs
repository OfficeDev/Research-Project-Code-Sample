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

namespace SpResearchTracker.Models
{
    public interface IProjectsRepository
    {
        Task<IEnumerable<Project>> GetProjects(string accessToken);
        Task<Project> GetProject(string accessToken, int Id, string eTag);
        Task<Project> CreateProject(string accessToken, Project project);
        Task<bool> UpdateProject(string accessToken, Project project);
        Task<bool> DeleteProject(string accessToken, int Id, string eTag);
    }
    public class ProjectsRepository : Repository, IProjectsRepository
    {
        public async Task<IEnumerable<Project>> GetProjects(string accessToken)
        {
            List<Project> projects = new List<Project>();
            
            StringBuilder requestUri = new StringBuilder()
                .Append(this.SiteUrl)
                .Append("/_api/web/lists/getbyTitle('")
                .Append(this.ProjectsListName)
                .Append("')/items?$select=ID,Title");

            HttpResponseMessage response = await this.Get(requestUri.ToString(), accessToken);
            string responseString = await response.Content.ReadAsStringAsync();
            XElement root = XElement.Parse(responseString);
            
            foreach (XElement entryElem in root.Elements().Where(e => e.Name.LocalName == "entry"))
            {
                projects.Add(entryElem.ToProject());
            }

            return projects.AsQueryable();
        }

        public async Task<Project> GetProject(string accessToken, int Id, string eTag)
        {
            StringBuilder requestUri = new StringBuilder()
                .Append(this.SiteUrl)
                .Append("/_api/web/lists/getbyTitle('")
                .Append(this.ProjectsListName)
                .Append("')/getItemByStringId('")
                .Append(Id.ToString())
                .Append("')?$select=ID,Title");

            HttpResponseMessage response = await this.Get(requestUri.ToString(), accessToken, eTag);
            string responseString = await response.Content.ReadAsStringAsync();
            XElement root = XElement.Parse(responseString);

            return XElement.Parse(responseString).ToProject();

        }

        public async Task<Project> CreateProject(string accessToken, Project project)
        {
            StringBuilder requestUri = new StringBuilder()
                 .Append(this.SiteUrl)
                 .Append("/_api/web/lists/getbyTitle('")
                 .Append(this.ProjectsListName)
                 .Append("')/items");

            XElement entry = project.ToXElement();

            StringContent requestContent = new StringContent(entry.ToString());
            HttpResponseMessage response = await this.Post(requestUri.ToString(), accessToken, requestContent);
            string responseString = await response.Content.ReadAsStringAsync();

            return XElement.Parse(responseString).ToProject();

        }

        public async Task<bool> UpdateProject(string accessToken, Project project)
        {
            StringBuilder requestUri = new StringBuilder()
                .Append(this.SiteUrl)
                .Append("/_api/web/lists/getbyTitle('")
                .Append(this.ProjectsListName)
                .Append("')/getItemByStringId('")
                .Append(project.Id.ToString())
                .Append("')");

            XElement entry = project.ToXElement();

            StringContent requestContent = new StringContent(entry.ToString());
            HttpResponseMessage response = await this.Patch(requestUri.ToString(), accessToken, project.__eTag, requestContent);
            return response.IsSuccessStatusCode;
        }

        public async Task<bool> DeleteProject(string accessToken, int Id, string eTag)
        {
            StringBuilder requestUri = new StringBuilder()
                .Append(this.SiteUrl)
                .Append("/_api/web/lists/getbyTitle('")
                .Append(this.ProjectsListName)
                .Append("')/getItemByStringId('")
                .Append(Id.ToString())
                .Append("')");

            HttpResponseMessage response = await this.Delete(requestUri.ToString(), accessToken, eTag);
            return response.IsSuccessStatusCode;

        }
    }
}