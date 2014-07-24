/*
 * role: angular service for spinner working animation
 * desc: handles the implementation of the spinner control
 */
(function () {
  'use strict';

  // define service
  var serviceId = 'spinner';
  angular.module('common')
      .factory(serviceId, ['common', 'commonConfig', spinner]);

  // create the service
  function spinner(common, commonConfig) {
    var service = {
      spinnerHide: spinnerHide,
      spinnerShow: spinnerShow
    };

    return service;

    function spinnerHide() { spinnerToggle(false); }

    function spinnerShow(message) { spinnerToggle(true, message); }

    function spinnerToggle(show, message) {
      common.$broadcast(commonConfig.config.spinnerToggleEvent,{
                                                                  show: show,
                                                                  message: message
                                                                });
    }
  }
})();