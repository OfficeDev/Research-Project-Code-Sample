/*
 * role: view controller
 * desc: controller for the project detail view
 */
(function () {
  'use strict';

  // define controller
  var controllerId = 'projectDetailView';
  angular.module('app').controller(controllerId,
    ['$location', '$route', '$routeParams', '$modal', 'dataContextBreeze', 'common', projectDetailView]);

  // create controller
  function projectDetailView($location, $route, $routeParams, $modal, datacontext, common) {
    var vm = this;
    vm.pageTitle = $route.current.title;

    vm.goEdit = goEdit;
    vm.goList = goList;
    vm.hasReferences = false;

    // init controller
    init();

    function init() {
      var promises = [];

      // if id passed in, load item (otherwise redirect to list)
      var projectId = +$routeParams.projectId;
      if (projectId && projectId > 0) {
        promises.push(getItem(projectId));
      } else {
        // shouldn't hit this, because parent page should redirect if no id passed in
      }

      common.activateController(promises, controllerId);
    }

    // get an existing item (from cache ideally)
    function getItem(projectId) {
      return datacontext.getProjectById(projectId)
        .then(function (data) {
          return vm.project = data;
        });
    }

    // route to edit page
    function goEdit() {
      $modal.open({
        templateUrl: 'myProjectModalContent.html',
        controller: 'projectDetailEdit',
        resolve: {
          project: function () { return vm.project; }
        }
      });
    }

    // go back to the project list
    function goList() {
      $location.path('/projects/');
    }
  }
})();