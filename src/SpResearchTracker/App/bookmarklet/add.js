/*
 * role: view controller
 * desc: controller adding a new reference via bookmarklet
 */
(function () {
  'use strict';

  // define controller
  var controllerId = 'addbookmarklet';
  angular.module('app').controller(controllerId,
    ['$window', '$location', '$routeParams', 'dataContextBreeze', 'spinner', 'common', addbookmarklet]);

  // create controller
  function addbookmarklet($window, $location, $routeParams, datacontext, spinner, common) {
    var referrer = undefined;
    var vm = this;

    vm.goSave = goSave;
    vm.goCancel = goCancel;

    // init controller
    init();

    function init() {
      var promises = [];

      // if no URL passed in, redirect to app homepage
      if (!$routeParams.urlToAdd)
        $location.path('/');

      // get the url specified in the path
      //var regex = new RegExp('\\', 'gi');
      referrer = $routeParams.urlToAdd.replace(/\\/gi,'/');
      referrer = decodeURIComponent(referrer);

      promises.push(
        // get all projects
        datacontext.getProjects()
          .then(function (data) {
            vm.projects = data;
            vm.currentProject = data[0];
          })
          // create reference
          .then(function () {
            vm.reference = datacontext.createReference({ Url: referrer });
            vm.reference.Project = vm.projects[0];
          })
      );

      common.activateController(promises, controllerId);
    }

    // save the item
    function goSave() {
      spinner.spinnerShow('saving reference...');

      // fixup the project selected (only saving the ID)
      vm.reference.Project = vm.currentProject.Id;

      return datacontext.saveChanges()
        .then(function () {
          spinner.spinnerHide();
          closeWindow();
        });
    }

    // reset the changes
    function goCancel() {
      closeWindow();
    }

    // close the window
    function closeWindow() {
      $window.close();
    }
  }
})();