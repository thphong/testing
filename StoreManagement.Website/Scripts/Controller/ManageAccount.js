mdlCommon.controller('ManageStoreController',
['$scope', '$filter', '$controller', '$interpolate', '$sce',
    function ($scope, $filter, $controller, $interpolate, $sce) {
        $controller('ctrlPaging', { $scope: $scope });

        //General info
        $scope.AccountInfo = {
            AvailableAmount: "",
            UsedAmount: "",
            ChargedAmount: ""
        } 
        
        $scope.SelectedMonth = -1;
        $scope.SelectedYear = -1;

        $scope.AccountFormConfig = new ObjectDataConfig("T_Trans_StoreAccount", $scope);
        var object = $scope.AccountFormConfig.GetObject($scope.ParentStore);
        $scope.AccountFormConfig.CopyFields(object, $scope.AccountInfo);

        $scope.SelectMonth = function(item) 
        {
            $scope.SelectedMonth = item.Month;
            $scope.SelectedYear = item.Year;
        }

    }]);