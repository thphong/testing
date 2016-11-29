mdlCommon.controller('ActivityController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.AdditionalFilter = {
            Action: "0"
        };


        //test
    }]);