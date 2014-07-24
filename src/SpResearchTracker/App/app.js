/*
 * role: app bootstrapping
 * desc: core and first component of the single page app (SPA); defines the 
 *       SPA as a module named 'app', then imports a handful of core modules
 *       needed throught the app such as core angular, breeze and custom modules
 */
(function () {
  'use strict';

  // create the app
  var app = angular.module('app', [
    // ootb angular modules
    'ngRoute',      // app routing support
    'ngSanitize',   // fixes html issues with some data binding
    'ngAnimate',    // adds animation capabilities

    'ui.bootstrap',

    // breeze modules
    'breeze.angular',     // wires up breeze with angular automatically
    'breeze.directives',  // angular directives used in the validation UX

    // app modules
    'common'
  ]);

  // startup code - this runs before the app actually "starts"
  app.run(['$route', 'breeze.config', appStartup]);
  function appStartup($route, breezeConfig) {
    // $route - routes are loaded first
    // $breezeConfig - breeze global configuration module... triggers
    //    the initial load of the metadata from the WebAPI OData feed
    //    used throughout the app
  }
})();