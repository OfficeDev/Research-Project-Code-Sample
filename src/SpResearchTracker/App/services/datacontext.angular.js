/*
 * role: data context
 * desc: data context that leverages angular's $http service to make HTTP calls
 */
(function () {
  'use strict';

  // define factory
  var serviceId = 'dataContextAngular';
  angular.module('app').factory(serviceId,
    ['$http', '$q', dataContextAngular]);

  function dataContextAngular($http, $q) {

    // factory public signature
    return {
      initConfigurations: initConfigurations
    };

    // calls backend that will verify necessary stuff is loaded
    function initConfigurations() {
      var deferred = $q.defer();

      // use angular's $http service to issue async call to webAPI function
      //  which checks with the SharePoint site configured in web.config
      //  to ensure that the necessary lists are present before the app gets running
      $http({
        method: 'GET',
        url: '/api/Configurations'
      }).success(function (response) {
        deferred.resolve(true);
      }).error(function (data, status, headers, config) {
        deferred.reject(status);
      });

      return deferred.promise;
    }

  }
})();