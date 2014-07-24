/*
 * role: custom angular directives
 * desc: simplifies the use of a spinner control to show the app is 'busy'
 */
(function () {
  'use strict';

  // get a reference to the app module
  var app = angular.module('app');

  // define directive
  var directiveId = "msftSpinner";
  app.directive(directiveId,
    ['$window', dirSpinner]);

  // creates a new Spinner and sets its options
  // <div data-msft-spinner="vm.spinnerOptions"></div>
  function dirSpinner($window) {
    var directive = {
      link: link,
      restrict: 'A'
    };
    return directive;

    function link(scope, element, attrs) {
      scope.spinner = null;
      scope.$watch(attrs.msftSpinner, function (options) {
        if (scope.spinner) {
          scope.spinner.stop();
        }
        scope.spinner = new $window.Spinner(options);
        scope.spinner.spin(element[0]);
      }, true);
    }
  };

})();