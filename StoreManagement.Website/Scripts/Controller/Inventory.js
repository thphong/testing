mdlCommon.controller('InventoryController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('ProductQuanHistoryController', { $scope: $scope });

        $scope.AdditionalFilter = {
            InventoryProductGroup: "0",
            InventoryProductType: "0"
        };

        $scope.CurrentTab = "InventoryProduct";
        $scope.CurrentDate = new Date();

        $scope.SetCurrentTab = function (tab) {
            if (tab != $scope.CurrentTab) {
                $scope.CurrentTab = tab;
                $scope.ReloadGrid(tab);
            }
        }


    }]);