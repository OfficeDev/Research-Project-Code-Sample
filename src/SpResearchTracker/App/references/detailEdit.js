/*
 * role: view controller
 * desc: controller for the reference edit dialog
 */
(function () {
  'use strict';

  // define controller
  var controllerId = 'referenceDetailEdit';
  angular.module('app').controller(controllerId,
    ['$scope', '$modalInstance', '$location', 'dataContextBreeze', 'spinner', 'common', 'project', 'reference', referenceDetail]);

  // create controller
  function referenceDetail($scope, $modalInstance, $location, datacontext, spinner, common, project, reference) {
    var vm = $scope;
    vm.project = project;
    vm.reference = reference;

    vm.goSave = goSave;
    vm.goCancel = goCancel;
    vm.goDelete = goDelete;

    // init controller
    init();

    function init() {
      if (reference && +reference.Id && reference.Id > 0) {
        vm.pageTitle = "Edit Reference";
        vm.templateMode = 'edit';
      } else {
        vm.pageTitle = "Add Reference to Project";
        vm.templateMode = 'new';
      }

      // wire dirty checker
      wireUpEntityChangedHandler(vm.reference);
    }

    // listen for changes to fields in the entity
    //  and update flag to enable/disable save button
    function wireUpEntityChangedHandler(entity) {
      vm.entityIsDirty = false;
      // when a property changes on the entity
      entity.entityAspect.propertyChanged.subscribe(
        function (args) {
          // if the Title, Url or Notes properties changed, update flag
          switch (args.propertyName) {
            case 'Title':
            case 'Url':
            case 'Notes':
              vm.entityIsDirty = true;
          }
        });
    }

    // save the item
    function goSave() {
      // show the working animation
      spinner.spinnerShow('saving reference...');

      // if the reference doesn't have a project set to it, do it
      if (!vm.reference.Project) {
        vm.reference.Project = vm.project.Id;
      }

      // save all changes
      return datacontext.saveChanges()
        .then(function () {
          $modalInstance.close({ refresh: true });
          // hide the working animation
          spinner.spinnerHide();
          common.logger.logSuccess('reference saved');
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
      spinner.spinnerShow('deleting reference...');

      datacontext.deleteEntity(vm.reference)
        .then(function () {
          // close the dialog
          $modalInstance.close({ refresh: true });

          // hide the working animation
          spinner.spinnerHide();
          common.logger.logSuccess('reference deleted');
        });
    }

  }
})();