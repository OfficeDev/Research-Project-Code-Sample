using System.Web.Http.Controllers;
using SpResearchTracker.Models;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.Http;
using SpResearchTracker.Utils;

namespace SpResearchTracker.Controllers
{
    [Authorize]
    public class ConfigurationsController : ApiController
    {
        //This interface is used to support dependency injection
        private readonly IResearchRepository _repository;
        private readonly TokenProvider _tokenProvider;

        public ConfigurationsController(IResearchRepository repository)
        {
            _repository = repository;
            _tokenProvider = new TokenProvider();
        }

        /// <summary>
        /// Gets information about the current list configuration in SharePoint.
        /// If the appropriate lists do not exist, then they are created.
        /// Client applications can call this controller at startup to ensure
        /// SharePoint is properly configured.
        /// </summary>
        /// <returns>A collection of list names</returns>
        public async Task<IHttpActionResult> Get()
        {
            //Get access token to SharePoint
            string accessToken = await _tokenProvider.GetSharePointAccessToken();
            if (accessToken == null)
            {
                throw new UnauthorizedAccessException();
            }

            //Check to see if the lists exist
            bool projectsListExists = await _repository.ListExists(accessToken, ((Repository)_repository).ProjectsListName);
            bool referencesListExists = await _repository.ListExists(accessToken, ((Repository)_repository).ReferencesListName);

            //Create the "Projects" list, if necessary
            if (!projectsListExists)
            {
                bool projectsListCreated = await _repository.CreateList(accessToken, ((Repository)_repository).ProjectsListName, "100");
            }

            //Create the "References" list, if necessary
            if (!referencesListExists)
            {
                bool referencesListCreated = await _repository.CreateList(accessToken, ((Repository)_repository).ReferencesListName, "103");

                //Add required fields to the list
                if (referencesListCreated)
                {
                    bool projectNameFieldCreated = await _repository.AddFieldToList(accessToken, ((Repository)_repository).ReferencesListName, "Project", "2");
                }
            }

            //Return the names of the lists as validation that the configuration is correct
            List<ConfigurationInfo> configurations = await _repository.GetConfigurations(accessToken);
            return Ok<List<ConfigurationInfo>>(configurations); 

        }
    }
}
