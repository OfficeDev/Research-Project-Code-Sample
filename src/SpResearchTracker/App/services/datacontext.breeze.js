/*
 * role: data context
 * desc: data context that leverages the breeze library for all REST read/writes 
 *        to the WebAPIOData service that calls SharePoint's REST API on behalf
 *        of the user
 */
(function () {
  'use strict';

  // define factory
  var serviceId = 'dataContextBreeze';
  angular.module('app').factory(serviceId,
    ['$q', 'breeze.config', 'common', dataContextBreeze]);

  // create factory
  function dataContextBreeze($q, breezeConfig, common) {
    var entityManager;

    // keep track if we've already loaded the projects
    var areProjectsLoaded = false;

    // int the factory
    init();

    // service public signature
    return {
      getProjects: getProjects,
      getProjectById: getProjectById,
      getProjectReferences: getProjectReferences,
      createProject: createProject,
      createReference: createReference,

      saveChanges: saveChanges,
      revertChanges: revertChanges,
      deleteEntity: deleteEntity
    };

    function init() {
      // obtain instance of the entity manager
      entityManager = breezeConfig.entityManager;
    }

    // get all projects, sorted by title
    function getProjects(forceRemoteRefresh) {

      // if not forcing remote data source refresh
      if (areProjectsLoaded && !forceRemoteRefresh) {
        // try to get projects from local cache 
        var projects = breeze.EntityQuery
          .from('Projects')
          .orderBy('Title')
          .using(entityManager)
          .executeLocally();
        return $q.when(projects);
      }

      // get data from the server
      return breeze.EntityQuery
        .from('Projects')
        .orderBy('Title')
        .using(entityManager)
        .execute()
        .then(function (data) {
          areProjectsLoaded = true;
          return data.results;
        });
    }

    // create a new project entity
    //  all this does is create the entity in the breeze cache... it's saved later
    function createProject(initialValues) {
      var projectType = entityManager.metadataStore.getEntityType('Project');
      // create a new project entity
      var entity = entityManager.createEntity(projectType, initialValues);
      entity.Type = "SP.Data.Research_x0020_ProjectsListItem";
      entity["odata.type"] = 'SpResourceTracker.Models.Project';
      return entity;
    }

    // get a specific project
    function getProjectById(projectId) {
      // get a reference to the project entity
      var projectType = entityManager.metadataStore.getEntityType('Project');
      // try to get the project from the local cache...
      //  if not found, breeze then goes to the server to get the item
      return entityManager.fetchEntityByKey(projectType, projectId, true)
        .then(function (data) {
          return data.entity;
        });
    }

    // get all project references by a specific ID
    function getProjectReferences(projectId) {
      // get all references associated with a specific project 
      return breeze.EntityQuery
        .from('References')
        .where('Project', 'eq', "'" + projectId + "'")
        .using(entityManager)
        .execute()
        .then(function (data) {
          return data.results;
        })
        .catch(function (exception) {
          common.logger.logError('failed to retrieve project references', exception, controllerId);
        });
    }

    // create a new reference entity
    //  all this does it create the entity in the breeze cache...
    function createReference(initialValues) {
      var referenceType = entityManager.metadataStore.getEntityType('Reference');
      // create a new reference entity
      var entity = entityManager.createEntity(referenceType, initialValues);
      entity.Type = 'SP.Data.Research_x0020_ReferencesListItem';
      entity['odata.type'] = 'SpResourceTracker.Models.Reference';
      return entity;
    }

    // save a all changes
    function saveChanges() {
      // save all new/changed entities
      //  for this app, there is only ever one
      return entityManager.saveChanges()
        .catch(function (error) {
        throw error;
      });
    }

    // reject the changes
    function revertChanges() {
      entityManager.rejectChanges();
    }

    // mark the item for deletion and then save changes
    function deleteEntity(entity, supressSave) {
      // set the entity to a deleted state
      entity.entityAspect.setDeleted();

      // if not provided, don't assume supress save
      supressSave = supressSave !== undefined
        ? supressSave
        : false;

      // if not supressing a save (for batching later), submit save
      if (!supressSave) {
        return saveChanges();
      }
    }
  }
})();