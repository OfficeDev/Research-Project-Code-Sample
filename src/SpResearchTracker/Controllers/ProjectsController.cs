using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.ModelBinding;
using System.Web.Http.OData;
using System.Web.Http.OData.Query;
using System.Web.Http.OData.Routing;
using SpResearchTracker.Models;
using Microsoft.Data.OData;
using SpResearchTracker.Filters;
using System.Threading.Tasks;
using System.Web.Http.Results;
using SpResearchTracker.Utils;

namespace SpResearchTracker.Controllers
{
    [Authorize]
    [OAuthExceptionFilter]

    public class ProjectsController : ODataController
    {
        //This interface is used to support dependency injection
        private IProjectsRepository _repository;

        public ProjectsController(IProjectsRepository repository)
        {
            _repository = repository;
        }

        private static ODataValidationSettings _validationSettings = new ODataValidationSettings();


        // GET: odata/Projects
        [Queryable]
        public async Task<IHttpActionResult> GetProjects(ODataQueryOptions<Project> queryOptions)
        {
            //Get access token to SharePoint
            string accessToken = ((Repository)_repository).GetAccessToken();
            if (accessToken == null)
            {
                throw new UnauthorizedAccessException();
            }

            // validate the query.
            try
            {
                queryOptions.Validate(_validationSettings);
            }
            catch (ODataException ex)
            {
                return BadRequest(ex.Message);
            }

            //Get projects from SharePoint
            IEnumerable<Project> projects = await _repository.GetProjects(accessToken);
            return Ok<IQueryable<Project>>(projects.AsQueryable());
        }

        // GET: odata/Projects(5)
        public async Task<IHttpActionResult> GetProject([FromODataUri] int key, ODataQueryOptions<Project> queryOptions)
        {
            //Get access token to SharePoint
            string accessToken = ((Repository)_repository).GetAccessToken();
            if (accessToken == null)
            {
                throw new UnauthorizedAccessException();
            }

            // validate the query.
            try
            {
                queryOptions.Validate(_validationSettings);
            }
            catch (ODataException ex)
            {
                return BadRequest(ex.Message);
            }

            //Get project from SharePoint
            string eTag = Request.Headers.IfNoneMatch.ToString();
            Project project = await _repository.GetProject(accessToken, key, eTag);

            //Check eTag
            if (project.__eTag == eTag)
            {
                return new StatusCodeResult(HttpStatusCode.NotModified, Request);
            }
            else
            {
                return Ok<Project>(project);
            }
        }

        // PUT: odata/Projects(5)
        public IHttpActionResult Put([FromODataUri] int key, Project project)
        {
            Request.ValidateAntiForgery();
            return StatusCode(HttpStatusCode.NotImplemented);
        }

        // POST: odata/Projects
        public async Task<IHttpActionResult> Post(Project project)
        {
            Request.ValidateAntiForgery();

            //Get access token to SharePoint
            string accessToken = ((Repository)_repository).GetAccessToken();
            if (accessToken == null)
            {
                throw new UnauthorizedAccessException();
            }

            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            Project newProject = await _repository.CreateProject(accessToken, project);

            return Created(newProject);
        }

        // PATCH: odata/Projects(5)
        [AcceptVerbs("PATCH", "MERGE")]
        public async Task<IHttpActionResult> Patch([FromODataUri] int key, Delta<Project> delta)
        {
            Request.ValidateAntiForgery();

            //Get access token to SharePoint
            string accessToken = ((Repository)_repository).GetAccessToken();
            if (accessToken == null)
            {
                throw new UnauthorizedAccessException();
            }

            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            //Get project from SharePoint
            Project changedProject = delta.GetEntity();
            changedProject.__eTag = Request.Headers.IfMatch.ToString();
            changedProject.Id = key;
            Project project = await _repository.GetProject(accessToken, changedProject.Id, changedProject.__eTag);

            if (String.IsNullOrEmpty(changedProject.__eTag))
            {
                changedProject.__eTag = "*";
            }

            if (changedProject.__eTag == project.__eTag ||
                changedProject.__eTag == "*")
            {
                if (await _repository.UpdateProject(accessToken, changedProject))
                {
                    return StatusCode(HttpStatusCode.NoContent);
                }
                else
                {
                    return StatusCode(HttpStatusCode.InternalServerError);
                }
            }
            else
            {
                return StatusCode(HttpStatusCode.Conflict);
            }
        }

        // DELETE: odata/Projects(5)
        public async Task<IHttpActionResult> Delete([FromODataUri] int key)
        {
            Request.ValidateAntiForgery();

            //Get access token to SharePoint
            string accessToken = ((Repository)_repository).GetAccessToken();
            if (accessToken == null)
            {
                throw new UnauthorizedAccessException();
            }

            //Get project from SharePoint
            string rootUri = Request.RequestUri.OriginalString.Substring(0, Request.RequestUri.OriginalString.IndexOf(Request.GetODataPath().Segments[0].ToString()));
            string eTag = Request.Headers.IfMatch.ToString();
            Project project = await _repository.GetProject(accessToken, key, eTag);

            if (eTag == string.Empty || eTag == null)
            {
                eTag = "*";
            }

            if (eTag == project.__eTag || eTag == "*")
            {
                if (await _repository.DeleteProject(accessToken, key, eTag))
                {
                    return StatusCode(HttpStatusCode.NoContent);
                }
                else
                {
                    return StatusCode(HttpStatusCode.InternalServerError);
                }
            }
            else
            {
                return StatusCode(HttpStatusCode.Conflict);
            }
        }
    }
}
