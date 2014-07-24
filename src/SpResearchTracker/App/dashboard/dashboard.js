/*
 * role: view controller
 * desc: controller for the dashboard view
 */
(function () {
  'use strict';

  // define controller
  var controllerId = 'dashboard';
  angular.module('app').controller(controllerId,
    ['$route', 'common', dashboard]);

  // create controller
  function dashboard($route, common) {
    var vm = this;
    vm.thisView = "dashboard view";

    // init controller
    init();

    function init() {
      common.activateController([], controllerId);
    }
  }
})();