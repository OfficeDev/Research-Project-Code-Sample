/*
 * role: view controller
 * desc: controller for the project detail view
 */
(function() {
    'use strict';

    // define controller
    var controllerId = 'projectDetailView';
    angular.module('app').controller(controllerId,
    ['$rootScope', '$location', '$route', '$routeParams', '$modal', 'dataContextBreeze', 'spinner', 'common', projectDetailView]);

    // create controller
    function projectDetailView($rootScope, $location, $route, $routeParams, $modal, datacontext,spinner, common) {
        var vm = this;
        
        vm.goEdit = goEdit;
        vm.goList = goList;
        vm.hasReferences = false;
        vm.references = [];


        function init() {
            var promises = [];

            // if id passed in, load item (otherwise redirect to list)
            var projectId = +$routeParams.projectId;
            if (projectId && projectId > 0) {
                promises.push(getItem(projectId));
            } else {
                // shouldn't hit this, because parent page should redirect if no id passed in
            }

            common.activateController(promises, controllerId);
        }

        // get an existing item (from cache ideally)
        function getItem(projectId) {
            return datacontext.getProjectById(projectId)
                .then(function(data) {
                     vm.project = data;
                     return getReferences();
            });
        }

        // route to edit page
        function goEdit() {
            $modal.open({
                templateUrl: 'myProjectModalContent.html',
                controller: 'projectDetailEdit',
                resolve: {
                    project: function() { return vm.project; }
                }
            });
        }

        // go back to the project list
        function goList() {
            $location.path('/projects/');
        }

        // add a reference to the project
        function goNewReference () {
            var modal = $modal.open({
                templateUrl: 'myReferenceModalContent.html',
                controller: 'referenceDetailEdit',
                resolve: {
                    project: function () { return vm.project; },
                    reference: function () { return datacontext.createReference({ project: vm.project.Id }); }
                }
            });

            // update the list of references with the local cache
            return modal.result.then(function () {
                return getReferences(vm.project.Id);
            });
        }

        // get all references for the specified project
        function getReferences() {
            spinner.spinnerShow('Loading References...');
            return datacontext.getProjectReferences(vm.project.Id)
                .then(function (data) {
                    if (data.length > 0) {
                        vm.hasReferences = true;
                        vm.references = data;                                                
                    }
                    spinner.spinnerHide();
                });
        }

        // open a new window and take them to a new reference
        vm.goReference = function (reference) {
            $location.path('/projects/' + vm.project.Id + '/reference/' + reference.Id);
        }
        $rootScope.$broadcast('navChanged', {
            showBack: true,
            backAction: function () {
                vm.goList();
            },
            items: [
                { text: 'Add', icon: 'glyphicon glyphicon-plus', action: goNewReference, title: 'Add a new reference' },
                { text: 'Refresh', icon: 'glyphicon glyphicon-refresh', action: getReferences, title: 'Refreshes the list of references' },
                { text: 'Edit', icon: 'glyphicon glyphicon-pencil', action: goEdit, title: 'Edit the project' }
            ]
        });
        // init controller
        init();
    }
})();