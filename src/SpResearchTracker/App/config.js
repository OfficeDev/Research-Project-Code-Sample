/*
 * role: global app configuration
 * desc: used for global app configuration
 */
(function () {
  'use strict';

  // get a reference to the app module
  var app = angular.module('app');

  // configure the toastr notifications
  toastr.options.timeOut = 3000;
  toastr.options.positionClass = 'toast-top-right';

  // collection of events used throughout the app
  var events = {
    // event when the controller has been successfully activated
    controllerActivateSuccess: 'controller.activateSuccess',
    // event when the working animation is triggered
    spinnerToggle: 'spinner.toggle'
  };

  // create global static config object
  var config = {
    title: 'Project Research Tracker App',
    version: '1.0.0.0',
    appErrorPrefix: "[SYSERR] ",
    events: events
  };
  app.value('config', config);

  // setup the angular logging provider to debug=on
  app.config(['$logProvider', function($logProvider) {
    if ($logProvider.debugEnabled) {
      $logProvider.debugEnabled(true);
    }
  }]);

  // configure the common configuration
  app.config(['commonConfigProvider', function (cfg) {
    // setup app events
    cfg.config.controllerActivateSuccessEvent = config.events.controllerActivateSuccess;
    cfg.config.spinnerToggleEvent = config.events.spinnerToggle;
  }]);
})();