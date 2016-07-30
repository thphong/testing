mdlCommon.controller('DataLogController',
['$scope', '$filter', '$controller', '$sce',
    function ($scope, $filter, $controller, $sce) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.AdditionalFilter = {
            Table: ""
        };

        $scope.ConvertTrustHtml = function (html) {
            return $sce.trustAsHtml(html);
        };

    }]);