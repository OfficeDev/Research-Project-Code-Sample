/*
 * role: custom angular directives
 * desc: simplifies the use of a spinner control to show the app is 'busy'
 */
(function () {
    'use strict';

    // get a reference to the app module
    var app = angular.module('app');

    // define service
    var directiveId = "navigation";
    app.factory(directiveId,
      [navigationCtor]);

    function navigationCtor() {
        return {items: [], showBack: false, backUrl: ''}
    };

    app.controller('Navigation', ['$scope', '$rootScope', function ($scope, $rootScope) {
        $scope.nav = navigationCtor();

        $rootScope.$on('navChanged', function (event, data) {

            $scope.nav.items = data.items;
            if (data.showBack !== undefined) {
                $scope.nav.showBack = data.showBack;
            }
            if (data.backAction !== undefined) {
                $scope.nav.backAction = data.backAction;
            }
        });
    }]);
})();