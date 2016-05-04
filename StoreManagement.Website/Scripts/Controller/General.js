mdlCommon.controller('GeneralController',
['$scope', '$filter', '$controller', 
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });

        var configList = new GridViewConfig("");
        configList.GridDataAction = "getall";
        configList.GridDataType = "function";
        configList.GridDataObject = "dbo.UFN_Report_General";
        configList.GridDefinedColums = "Revenue;NumOrder;NumSoldProduct;ReturnAmount;LongInventory;OutOfQuantity;UnderMin;OverMax;TotalProduct;NotInputPrice;NotInputCost;NotInputGroup";
        configList.GridParameters = $scope.CurrentUser + "," + $scope.CurrentStore;
        
        $scope.GeneralInfo = configList.GetListData()[0];

    }]);