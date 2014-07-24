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
    public class ReferencesController : ODataController
    {
        //This interface is used to support dependency injection
        private IReferencesRepository _repository;

        public ReferencesController(IReferencesRepository repository)
        {
            _repository = repository;
        }

        private static ODataValidationSettings _validationSettings = new ODataValidationSettings();

        // GET: odata/References
        [Queryable]
        public async Task<IHttpActionResult> GetReferences(ODataQueryOptions<Reference> queryOptions)
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
            IEnumerable<Reference> references = await _repository.GetReferences(accessToken);
            return Ok<IQueryable<Reference>>(references.AsQueryable());
        }

        // GET: odata/References(5)
        public async Task<IHttpActionResult> GetReference([FromODataUri] int key, ODataQueryOptions<Reference> queryOptions)
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

            //Get reference from SharePoint
            string eTag = Request.Headers.IfNoneMatch.ToString();
            Reference reference = await _repository.GetReference(accessToken, key, eTag);

            //Check eTag
            if (reference.__eTag == eTag)
            {
                return new StatusCodeResult(HttpStatusCode.NotModified, Request);
            }
            else
            {
                return Ok<Reference>(reference);
            }
        }

        // PUT: odata/References(5)
        public IHttpActionResult Put([FromODataUri] int key, Reference reference)
        {
            Request.ValidateAntiForgery();
            return StatusCode(HttpStatusCode.NotImplemented);
        }

        // POST: odata/References
        public async Task<IHttpActionResult> Post(Reference reference)
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

            Reference newReference = await _repository.CreateReference(accessToken, reference);

            return Created(newReference);
        }

        // PATCH: odata/References(5)
        [AcceptVerbs("PATCH", "MERGE")]
        public async Task<IHttpActionResult> Patch([FromODataUri] int key, Delta<Reference> delta)
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

            //Get current reference from SharePoint
            Reference changedRef = delta.GetEntity();
            changedRef.__eTag = Request.Headers.IfMatch.ToString();
            changedRef.Id = key;
            Reference storedRef = await _repository.GetReference(accessToken, changedRef.Id, changedRef.__eTag);
            
            //Prepare updated reference for commit
            if (String.IsNullOrEmpty(changedRef.Title))
            {
                changedRef.Title = storedRef.Title;
            }
            if (String.IsNullOrEmpty(changedRef.Url))
            {
                changedRef.Url = storedRef.Url;
            }
            if (String.IsNullOrEmpty(changedRef.Notes))
            {
                changedRef.Notes = storedRef.Notes;
            }
            if (String.IsNullOrEmpty(changedRef.Project))
            {
                changedRef.Project = storedRef.Project;
            }

            if ( String.IsNullOrEmpty(changedRef.__eTag))
            {
                changedRef.__eTag = "*";
            }

            if (changedRef.__eTag == storedRef.__eTag ||
                changedRef.__eTag == "*")
            {
                if (await _repository.UpdateReference(accessToken, changedRef))
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

        // DELETE: odata/References(5)
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
            string eTag = Request.Headers.IfMatch.ToString();
            Reference reference = await _repository.GetReference(accessToken, key, eTag);

            if (eTag == string.Empty || eTag == null)
            {
                eTag = "*";
            }

            if (eTag == reference.__eTag || eTag == "*")
            {
                if (await _repository.DeleteReference(accessToken, key, eTag))
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
