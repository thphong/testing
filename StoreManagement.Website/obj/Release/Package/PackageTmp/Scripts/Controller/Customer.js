mdlCommon.controller('CustomerController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('CustomerModalController', { $scope: $scope });
        $controller('SupplierModalController', { $scope: $scope });

        $scope.AdditionalFilter = {
            CustomerType: "0",
            SaleCustomerType: "0",
            SupplierType: "0"
        };

        $scope.CurrentTab = "Customers";

        $scope.SetCurrentTab = function (tab) {
            if (tab != $scope.CurrentTab) {
                $scope.CurrentTab = tab;
                $scope.IsShowCustomerDetail = false;
                $scope.IsShowSupplierDetail = false;
                //$scope.ReloadGrid(tab);
            }
        }

    }]);