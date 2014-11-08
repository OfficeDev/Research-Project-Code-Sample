using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web.Http;
using System.Web.Http.Controllers;
using System.Web.Http.OData;
using System.Web.Http.OData.Query;
using SpResearchTracker.Models;
using Microsoft.Data.OData;
using System.Threading.Tasks;
using System.Web.Http.Results;
using SpResearchTracker.Utils;

namespace SpResearchTracker.Controllers
{
    [Authorize]
    public class ProjectsController : ODataController
    {
        private static readonly ODataValidationSettings _validationSettings = new ODataValidationSettings();
        
        //This interface is used to support dependency injection
        private readonly IProjectsRepository _repository;
        private AccessTokenProvider _tokenProvider;

        public ProjectsController(IProjectsRepository repository)
        {
            _repository = repository;
        }

        protected override void Initialize(HttpControllerContext controllerContext)
        {
            base.Initialize(controllerContext);
            _tokenProvider = new AccessTokenProvider(Request);
        }

        // GET: odata/Projects
        [Queryable]
        public async Task<IHttpActionResult> GetProjects(ODataQueryOptions<Project> queryOptions)
        {
            //Get access token to SharePoint
            string accessToken = await _tokenProvider.GetAccessToken();
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
            return Ok(projects.AsQueryable());
        }

        // GET: odata/Projects(5)
        public async Task<IHttpActionResult> GetProject([FromODataUri] int key, ODataQueryOptions<Project> queryOptions)
        {
            //Get access token to SharePoint
            string accessToken = await _tokenProvider.GetAccessToken();
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
                return Ok(project);
            }
        }

        // PUT: odata/Projects(5)
        public IHttpActionResult Put([FromODataUri] int key, Project project)
        {
            return StatusCode(HttpStatusCode.NotImplemented);
        }

        // POST: odata/Projects
        public async Task<IHttpActionResult> Post(Project project)
        {

            //Get access token to SharePoint
            string accessToken = await _tokenProvider.GetAccessToken();
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

            //Get access token to SharePoint
            string accessToken = await _tokenProvider.GetAccessToken();
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

            //Get access token to SharePoint
            string accessToken = await _tokenProvider.GetAccessToken();
            if (accessToken == null)
            {
                throw new UnauthorizedAccessException();
            }

            //Get project from SharePoint
            //string rootUri = Request.RequestUri.OriginalString.Substring(0, Request.RequestUri.OriginalString.IndexOf(Request.GetODataPath().Segments[0].ToString()));
            string eTag = Request.Headers.IfMatch.ToString();
            Project project = await _repository.GetProject(accessToken, key, eTag);

            if (String.IsNullOrEmpty(eTag))
            {
                eTag = "*";
            }

            if (eTag == project.__eTag || eTag == "*")
            {
                if (await _repository.DeleteProject(accessToken, key, eTag))
                {
                    return StatusCode(HttpStatusCode.NoContent);
                }
                
                return StatusCode(HttpStatusCode.InternalServerError);
            }

            return StatusCode(HttpStatusCode.Conflict);
        }
    }
}
