/*
 * role: global configuration of angular's service
 * desc: used for global config of any angular service, such as setting the ACCEPT
 *       request header to include in all requests issed by angular's $http service
 */
(function () {
  'use strict';

  // define service
  var serviceId = 'angular.config';
  angular.module('app').factory(serviceId,
    ['$http', configAngular]);

  // create service
  function configAngular($http) {
    // init factory
    init();

    // service public signature
    return {};

    // init factory
    function init() {
      // set common $http request headers
      $http.defaults.headers.common.Accept = 'application/json;odata=verbose;';
    }
  }

})();