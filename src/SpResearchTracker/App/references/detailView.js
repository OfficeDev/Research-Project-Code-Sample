/* role: view controller
* desc: controller for the project detail view
*/
(function() {
    'use strict';

    // define controller
    var controllerId = 'referenceDetailView';
    angular.module('app').controller(controllerId,
    ['$rootScope', '$location', '$route', '$routeParams', '$modal', 'dataContextBreeze', 'spinner', 'common', referenceDetailView]);

    // create controller
    function referenceDetailView($rootScope, $location, $route, $routeParams, $modal, datacontext, spinner, common) {
        var vm = this;
        vm.reference = undefined;
        var referenceId = +$routeParams.referenceId;
        var projectId = +$routeParams.projectId;

        function init() {
            var promises = [];

            // if id passed in, load item (otherwise redirect to list)
            if (referenceId && projectId && projectId > 0 && referenceId > 0) {
                promises.push(getItem(projectId, referenceId));
            } else {
                // shouldn't hit this, because parent page should redirect if no id passed in
            }

            common.activateController(promises, controllerId);
        }

        function getItem() {
            spinner.spinnerShow('Loading Reference...');
            return datacontext.getProjectById(projectId)
                .then(function(data) {
                    vm.project = data;
                    datacontext.getProjectReferenceById(projectId, referenceId)
                        .then(function(data) {
                            spinner.spinnerHide();
                            return vm.reference = data;
                        });
                });
        }


        // route to edit page
        function goEdit() {
            $modal.open({
                templateUrl: 'myReferenceModalContent.html',
                controller: 'referenceDetailEdit',
                resolve: {
                    project: function () { return vm.project; },
                    reference: function() { return vm.reference; }
                }
            });
        }

        $rootScope.$broadcast('navChanged', {
            showBack: true,
            backAction: function() {
                $location.path('projects/' + vm.project.Id);
            },
            items: [{ text: 'Refresh', icon: 'glyphicon glyphicon-refresh', action: getItem, title: 'Refreshes the reference' },
                    { text: 'Edit', icon: 'glyphicon glyphicon-pencil', action: goEdit, title: 'Edit the reference' }]
        });

        init();
    }

})();