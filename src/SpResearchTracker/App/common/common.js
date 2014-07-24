/*
 * role: common module
 * desc: global functionality used across app
 */
(function () {
  'use strict';

  // create module
  var commonModule = angular.module('common', []);

  // create provider
  commonModule.provider('commonConfig', function () {
    this.config = {};

    this.$get = function () {
      return {
        config: this.config
      };
    };
  });

  // create the common service
  commonModule.factory('common',
    ['$window', '$q', '$rootScope', '$timeout', 'logger', 'commonConfig', common]);

  // create the factory 'common'
  function common($window, $q, $rootScope, $timeout, logger, commonConfig) {
    // public signature of module
    var service = {
      // pass though common angular dependencies
      $broadcast: $broadcast,
      $q: $q,
      $timeout: $timeout,
      // my services
      activateController: activateController,
      logger: logger,
      // global util functions
      goBack: goBack
    };
    return service;

    // pass through of the angular $broadcast service
    function $broadcast() {
      return $rootScope.$broadcast.apply($rootScope, arguments);
    }

    // global function used to activate a controller once all promises have completed
    function activateController(promises, controllerId) {
      return $q.all(promises).then(function () {
        var data = { controllerId: controllerId };
        $broadcast(commonConfig.config.controllerActivateSuccessEvent, data);
      });
    }

    // navigate backwards in the history stack
    function goBack() {
      $window.history.back();
    }
  }
})();