/*
 * role: logger controller
 * desc: used to control the logging framework
 */
(function (window) {
  'use strict';

  // define factory
  angular.module('common').factory('logger',
    ['$log', 'config', logger]);

  // create factory
  function logger($log) {
    var service = {
      forSource: forSource,
      log: log,
      logError: logError,
      logSuccess: logSuccess,
      logWarning: logWarning
    };

    return service;

    // #region public members
    function forSource(src) {
      return {
        log: function (m, d, s) { log(m, d, src, s); },
        logError: function (m, d, s) { logError(m, d, src, s); },
        logSuccess: function (m, d, s) { logSuccess(m, d, src, s); },
        logWarning: function (m, d, s) { logWarning(m, d, src, s); }
      };
    }

    function log(message, data, source, showNotification) {
      writeLog(message, data, source, showNotification, "info");
    }

    function logError(message, data, source, showNotification) {
      writeLog(message, data, source, showNotification, "error");
    }

    function logSuccess(message, data, source, showNotification) {
      writeLog(message, data, source, showNotification, "success");
    }

    function logWarning(message, data, source, showNotification) {
      writeLog(message, data, source, showNotification, "warning");
    }
    // #endregion

    // #region private members
    // universal method for writing notifications
    function writeLog(message, data, source, showNotification, notificationType) {
      showNotification = showNotification == null ? true : showNotification;

      // write to angular log, & specify error if it is an error
      var write = (notificationType === 'error') ? $log.error : $log.log;
      source = source ? '[' + source + '] ' : '';
      write(source, message, data);

      if (showNotification) {
        if (notificationType === 'error') {
          toastr.error(message);
        } else if (notificationType === 'warning') {
          toastr.warning(message);
        } else if (notificationType === 'success') {
          toastr.success(message);
        }

      }
    }
    // #endregion
  }
})(this);