$(document).ready(function () {
    $('input.datepicker').datepicker({ format: 'dd-mm-yyyy'/*, startDate: '23-03-2016'*/ });
});

mdlCommon.controller('InventoryController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('ProductQuanHistoryController', { $scope: $scope });

        $scope.AdditionalFilter = {
            InventoryProductGroup: "0",
            InventoryProductType: "0",
            InventoryInOutProductGroup: "0",
            InventoryInOutStartDate: "",
            InventoryInOutEndDate: ""
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