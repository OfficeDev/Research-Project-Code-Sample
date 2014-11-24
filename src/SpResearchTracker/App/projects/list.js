/*
 * role: view controller
 * desc: controller for the project list view
 */
(function () {
  'use strict';

  // define controller
  var controllerId = 'projectList';
  angular.module('app').controller(controllerId,
    ['$rootScope', '$location', '$timeout', '$modal', 'dataContextBreeze', 'spinner', 'common', projectList]);

  // create controller
  function projectList($rootScope, $location, $timeout, $modal, datacontext, spinner, common) {
      var vm = this;

      $rootScope.$broadcast('navChanged', {
          showBack: false, items: [
              { text: 'Add', icon: 'glyphicon glyphicon-plus', action: goNewProject, title: 'Add a new project' },
              { text: 'Refresh', icon: 'glyphicon glyphicon-refresh', action: goRefresh, title: 'Refreshes the list of projects' }]
      });
    vm.goNewProject = goNewProject;
    vm.goRefresh = goRefresh;
    vm.goProjectDetail = goProjectDetail;

    // init controller
    init();

    function init() {
      common.activateController([getAllProjects()], controllerId);
    }

    // retrieve all projects form the server
    function getAllProjects(forceRefresh) {
      // show working animation
      spinner.spinnerShow('loading projects...');

      return datacontext.getProjects(forceRefresh)
        .then(function (data) {
          spinner.spinnerHide();
          return vm.projects = data;
        })
        .catch(function (err) {
          throw new Error("error obtaining data: " + err);
        });
    }

    // refresh the project list
    function goRefresh() {
      // clear out the existing projects
      vm.projects = [];

      // force a refresh of all projects 
      return getAllProjects(true);
    }

    // redirects to the new project page
    function goNewProject() {
      var modal = $modal.open({
        templateUrl: 'myProjectModalContent.html',
        controller: 'projectDetailEdit',
        resolve: {
          project: function () { return datacontext.createProject(); }
        }
      });

      // update the list of projects with the local cache
      return modal.result.then(function() {
        return getAllProjects(false);
      });
    }

    // navigate to the detail page
    function goProjectDetail(project) {
      if (project && project.Id) {
        $location.path('/projects/' + project.Id);
      }

    }
  }
})();