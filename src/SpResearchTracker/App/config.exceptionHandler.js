/*
 * role: angular logging extension to app custom logging
 * desc: hooks into angular's error handing to bubble an error in the 
         system up to the app logging
 */
(function () {
  'use strict';

  var app = angular.module('app');

  app.config(function ($provide) {
    $provide.decorator('$exceptionHandler',
                        ['$delegate', 'config', 'logger', extendExceptionHandler]);
  });

  // Extend $exceptionHandler service to display error notification
  function extendExceptionHandler($delegate, config, logger) {
    var appErrorPrefix = config.appErrorPrefix;

    return function (exception, cause) {
      $delegate(exception, cause);
      if (appErrorPrefix && exception.message.indexOf(appErrorPrefix) === 0) { return; }

      var errorData = {
        exception: exception,
        cause: cause
      };

      var msg = appErrorPrefix + exception.message;

      logger.logError(msg, errorData, true);
    };
  }
})();