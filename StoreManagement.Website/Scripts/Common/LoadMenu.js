mdlCommon.controller('LoadMenuController',
['$scope', '$filter', '$controller', '$interpolate',
    function ($scope, $filter, $controller, $interpolate) {
        $controller('ctrlPaging', { $scope: $scope });


        $scope.CurrentStore = g_currentStoreId;
        $scope.CurrentUrl = window.location.pathname.toLowerCase();

        var configMenuList = new GridViewConfig("");
        configMenuList.GridDataAction = "getall";
        configMenuList.GridDataType = "function";
        configMenuList.GridDataObject = "dbo.UFN_System_Get_Menu";
        configMenuList.GridParametersExpression = "{{CurrentUser}}";
        configMenuList.OrderBy = "DisplayOrder";

        if ($scope.CurrentStore > 0) {
            configMenuList.EvaluateFieldExpression($interpolate, $scope);
            $scope.ListMenu = configMenuList.GetListData();
        }

        $scope.SetStoreId = function () {
            AjaxSync(g_setStoreIdUrl, '{ "storedId": "' + $scope.CurrentStore + '"}');
            location.reload();
        }

        $scope.LogIn = function () {
            AjaxSync(g_setStoreIdUrl, '{ "storedId": "' + $scope.CurrentStore + '"}');
            location.reload();
        }

        $scope.LoginInfo =
        {
            LoginId: "",
            Password : ""
        };

    }]);