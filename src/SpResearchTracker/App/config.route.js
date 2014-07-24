/*
 * role: global route setup for app
 * desc: defines & loads all routes supported in the route
 */
(function () {
  'use strict';

  // get a reference to the app module
  var app = angular.module('app');

  // put all routes into global constant
  app.constant('routes', getRoutes());

  // config the routes & their resolvers
  app.config(['$routeProvider', 'routes', routeConfigurator]);
  function routeConfigurator($routeProvider, routes) {
    // load all routes into the system
    routes.forEach(function (route) {
      $routeProvider.when(route.url, route.config);
    });
    // if a route isn't found, send to spa's 404
    $routeProvider.otherwise({ redirectTo: '/' });
  }

  // build routes
  function getRoutes() {
    return [
      {
        url: '/',
        config: {
          templateUrl: '/App/dashboard/dashboard.html',
          title: 'Dashboard'
        }
      },
      // projects
      {
        url: '/projects',
        config: {
          templateUrl: '/App/projects/list.html',
          title: 'Projects'
        }
      },
      {
        url: '/projects/:projectId',
        config: {
          templateUrl: '/App/projects/detailView.html',
          title: 'View an Existing Project',
          templateMode: 'view'
        }
      },
      {
        url: '/addreference/:urlToAdd',
        config: {
          templateUrl: '/App/bookmarklet/add.html',
          title: 'Add Reference via Bookmarklet',
          templateMode: 'add'
        }
      }
    ];
  }
})();