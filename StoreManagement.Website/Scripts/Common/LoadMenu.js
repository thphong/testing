mdlCommon.controller('LoadMenuController',
['$scope', '$filter', '$controller', '$interpolate',
    function ($scope, $filter, $controller, $interpolate) {
        $controller('ctrlPaging', { $scope: $scope });


        var configMenuList = new GridViewConfig("");
        configMenuList.GridDataAction = "getall";
        configMenuList.GridDataType = "function";
        configMenuList.GridDataObject = "dbo.UFN_System_Get_Menu";
        configMenuList.GridParametersExpression = "{{CurrentUser}}";
        configMenuList.OrderBy = "DisplayOrder";

        configMenuList.EvaluateFieldExpression($interpolate, $scope);
        $scope.ListMenu = configMenuList.GetListData();
        $scope.CurrentUrl = window.location.pathname.toLowerCase();

    }]);