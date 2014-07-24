/*
 * role: view controller
 * desc: controller for the reference list view
 */
(function () {
  'use strict';

  // define controller
  var controllerId = 'referenceList';
  angular.module('app').controller(controllerId,
    ['$routeParams', '$location', '$modal', 'dataContextBreeze', 'common', referenceList]);

  // create controller
  function referenceList($routeParams, $location, $modal, datacontext, common) {
    var vm = this;
    vm.currentProject = undefined;
    vm.goEdit = goEdit;
    vm.goReference = goReference;
    vm.goNewReference = goNewReference;

    // init controller
    init();

    function init() {
      var promises = [];

      // get the project specified
      var projectId = +$routeParams.projectId;
      if (projectId && projectId > 0) {
        var promise = getProject(projectId)
          .then(function (project) {
            vm.currentProject = project;
            getReferences(vm.currentProject.Id);
          });
        promises.push(promise);
      } else {
        $location.path('/projects/');
      }

      common.activateController([promises], controllerId);
    }

    // route to edit dialog
    function goEdit(reference) {
      var modalInstance = $modal.open({
        templateUrl: 'myReferenceModalContent.html',
        controller: 'referenceDetailEdit',
        resolve: {
          project: function () { return vm.currentProject; },
          reference: function () { return reference; }
        }
      });

      // wire up handler when dialog closes
      modalInstance.result.then(function (result) {
        if (result && result.refresh && result.refresh == true) {
          getReferences(vm.currentProject.Id);
        }
      });
    }

    // get an existing item (from cache ideally)
    function getProject(projectId) {
      return datacontext.getProjectById(projectId)
        .then(function (data) {
          return vm.currentProject = data;
        });
    }

    // get all references for the specified project
    function getReferences(projectId) {
      return datacontext.getProjectReferences(projectId)
        .then(function (data) {
          if (data.length > 0) {
            vm.hasReferences = true;
            return vm.references = data;
          }
        });
    }

    // open a new window and take them to a new reference
    function goReference(reference) {
      window.open(reference.Url);
    }

    // add a reference to the project
    function goNewReference() {
      var modal = $modal.open({
        templateUrl: 'myReferenceModalContent.html',
        controller: 'referenceDetailEdit',
        resolve: {
          project: function () { return vm.currentProject; },
          reference: function () { return datacontext.createReference({ project: vm.currentProject.Id }); }
        }
      });

      // update the list of references with the local cache
      return modal.result.then(function () {
        return getReferences(vm.currentProject.Id);
      });
    }

  }
})();