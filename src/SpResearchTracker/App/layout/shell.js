/*
 * role: view controller
 * desc: controller for the shell view
 */
(function () {
  'use strict';

  // define controller
  var controllerId = 'shell';
  angular.module('app').controller(controllerId,
    ['$rootScope', '$route', 'dataContextAngular', 'common', 'config', shell]);

  // create controller
  function shell($rootScope, $route, dataContextAngular, common, config) {
    var vm = this;

    // Boolean property used to show/hide splash page
    vm.showSplashPage = true;

    // props to control the busy indicator
    vm.isBusy = true;
    vm.spinnerOptions = {
      radius: 20,
      lines: 15,
      length: 30,
      width: 10,
      speed: 1,
      corners: 1.0,
      trail: 60,
      color: '#52b9e9'
    };

    // init controller
    init();

    function init() {
      // wire handler to successful route changes to
      //  - update the page title (for bookmarking)
      $rootScope.$on('$routeChangeSuccess', function (event, current, previous) {
        if (!$route.current || !$route.current.title) {
          $rootScope.pageTitle = '';
        } else {
          $rootScope.pageTitle = ' > ' + $route.current.title;
        }
      });

      // activate this controller, then initialize the app (making
      //   sure the lists in the SharePoint site are present)
      //   then hide the splash page
      common.activateController([dataContextAngular.initConfigurations()], controllerId)
        .then(function () {
          // app ready, hide splash
          vm.showSplashPage = false;
        })
        .catch(function (error) {
          // if receiving an error page redirect to the NoAuth (401) view
          if (error == 401) {
            window.location = "/Home";
          }
        });

    }

    //#region spinner utils
    function toggleSpinner(on, message) {
      vm.isBusy = on;

      // if message passed in, use it
      if (message)
        vm.busyMessage = message;
    }

    // listen for the global event $routeChangeStart, triggered when
    //  moving from one view to another
    $rootScope.$on('$routeChangeStart', function (event, next, current) {
      toggleSpinner(true);
    });

    // listen for the custom event when controllers are activated successfully
    $rootScope.$on(config.events.controllerActivateSuccess, function (data, args) {
      if (args && args.controllerId && args.controllerId != 'shell') {
        toggleSpinner(false);
      }
    });

    // listen for the custom event when the spinner is toggled on/off
    $rootScope.$on(config.events.spinnerToggle, function (event, args) {
      var message = args.message ? args.message : '';

      toggleSpinner(args.show, message);
    });
    //#endregion
  }
})();