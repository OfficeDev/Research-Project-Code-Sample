/*
 * role: edit controller
 * desc: controller for the projects detail edit dialog
 */
(function () {
  'use strict';

  // define controller
  var controllerId = 'projectDetailEdit';
  angular.module('app').controller(controllerId,
    ['$scope', '$modalInstance', '$location', 'dataContextBreeze', 'spinner', 'common', 'project', projectDetailEdit]);

  // create controller
  function projectDetailEdit($scope, $modalInstance, $location, datacontext, spinner, common, project) {
    var vm = $scope;
    vm.project = project;

    vm.goSave = goSave;
    vm.goCancel = goCancel;
    vm.goDelete = goDelete;

    // init controller
    init();

    function init() {
      if (project && +project.Id && project.Id > 0) {
        vm.pageTitle = "Edit Project";
        vm.templateMode = 'edit';
      } else {
        vm.pageTitle = "Create New Project";
        vm.templateMode = 'new';
      }

      // wire dirty checker
      wireUpEntityChangedHandler(vm.project);
    }

    // listen for changes to fields in the entity
    //  and update flag to enable/disable save button
    function wireUpEntityChangedHandler(entity) {
      vm.entityIsDirty = false;
      // when a property changes on the entity
      entity.entityAspect.propertyChanged.subscribe(
        function (args) {
          // if the title property changed, update flag
          if (args.propertyName == 'Title') {
            vm.entityIsDirty = true;
          }
        });
    }

    // save the item
    function goSave() {
      // show the working animation
      spinner.spinnerShow('saving project...');

      return datacontext.saveChanges()
        .then(function () {
          $modalInstance.close(vm.project);
          // hide the working animation
          spinner.spinnerHide();
          common.logger.logSuccess('project saved');
        })
        .catch(function (error) {
          // hide the working animation
          spinner.spinnerHide();

          // if it's a conflict, then tell user they must refresh 
          //  the list of references before updating
          if (error.status && error.status == "409") {
            common.logger.logWarning('failed to update item that is newer on the server; refresh list before updating the item');
          } else {
            common.logger.logError('unknown error occured');
          }
        });
    }

    // reset the changes
    function goCancel() {
      // cancel any changes to the item
      datacontext.revertChanges();
      // close the modal dialog
      $modalInstance.dismiss('cancel');
    }

    // delete entities
    function goDelete() {
      // show the working animation
      spinner.spinnerShow('deleting references in project...');

      // get all references
      return datacontext.getProjectReferences(vm.project.Id)
        .then(function (references) {
          // loop through all references...
          for (var index = 0; index < references.length; index++) {
            // set each to deleted, but supress the save call to the 
            //  service... let the deletion of the project that will
            //  follow be the one that issues the batch delete
            datacontext.deleteEntity(references[index], true);
          }
        })
        .then(function () {
          // delete the project
          spinner.spinnerShow('deleting project...');
          return datacontext.deleteEntity(vm.project)
            .then(function () {
              // close the dialog & navigate back to the project list page
              $modalInstance.close(
                $location.path('/projects/')
                );

              // hide the working animation
              spinner.spinnerHide();
              common.logger.logSuccess('project deleted');
            });
        });

    }

  }
})();