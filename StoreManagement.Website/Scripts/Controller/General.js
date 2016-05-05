mdlCommon.controller('GeneralController',
['$scope', '$filter', '$controller', '$interpolate',
    function ($scope, $filter, $controller, $interpolate) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.ConfigList = new GridViewConfig("");
        $scope.ConfigList.GridDataAction = "getall";
        $scope.ConfigList.GridDataType = "function";
        $scope.ConfigList.GridDataObject = "dbo.UFN_Report_General";
        $scope.ConfigList.GridDefinedColums = "Revenue;NumOrder;NumSoldProduct;ReturnAmount;LongInventory;OutOfQuantity;UnderMin;OverMax;TotalProduct;NotInputPrice;NotInputCost;NotInputGroup";
        $scope.ConfigList.GridParameters = $scope.CurrentUser + "," + $scope.CurrentStore;
        
        $scope.GeneralInfo = $scope.ConfigList.GetListData()[0];

        $scope.SetFilterRangeDate(1, "");
        $scope.ConfigList.GridDataObject = "dbo.UFN_Report_Profit_By_Store";
        $scope.ConfigList.GridDefinedColums = "Quantity;Revenue;ReturnAmount;Cost;Profit";
        $scope.ConfigList.GridParametersExpression = "{{CurrentUser}},dbo.UFN_System_GetDateTime(''{{FilterRangeDate.StartDate}}'', ''dd-MM-yyyy''),dbo.UFN_System_GetDateTime(''{{FilterRangeDate.EndDate}}'', ''dd-MM-yyyy''), {{CurrentStore}}";
        
        $scope.Revenue =
        {
            Data: {}
        }

        $scope.ShowRevenue = function()
        {
            $scope.ConfigList.EvaluateFieldExpression($interpolate, $scope);
            $scope.Revenue.Data = $scope.ConfigList.GetListData()[0];
        }

        $scope.ShowRevenue();
    }]);