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

        if ($scope.CurrentUser > 0) {
            configMenuList.EvaluateFieldExpression($interpolate, $scope);
            $scope.ListMenu = configMenuList.GetListData();
        }

        $scope.SetStoreId = function (storeId) {
            if ($scope.CurrentStore != storeId) {
                AjaxSync(g_setStoreIdUrl, '{ "storedId": ' + storeId + '}');
                location.reload();
            }
        }

        $scope.LogIn = function () {
            if (FValidation.CheckControls("")) {
                var result = AjaxSync(g_loginUrl, '{ "loginId": "' + $scope.LoginInfo.LoginId + '", "password": "' + $scope.LoginInfo.Password + '"}');
                if (result) {
                    if (typeof (Storage) !== "undefined") {
                        // Store
                        if ($scope.LoginInfo.Remember) {
                            localStorage.setItem("SM_LoginId", $scope.LoginInfo.LoginId);
                            localStorage.setItem("SM_Password", $scope.LoginInfo.Password);
                            localStorage.setItem("SM_Remember", $scope.LoginInfo.Remember);
                        }
                        else {
                            localStorage.setItem("SM_LoginId", "");
                            localStorage.setItem("SM_Password", "");
                            localStorage.setItem("SM_Remember", $scope.LoginInfo.Remember);
                        }
                    }

                    location.reload();
                }
                else {
                    ShowErrorMessage("Tài khoản không hợp lệ.");
                }
            }
        }

        $scope.LogOut = function () {
            var result = AjaxSync(g_logoutUrl, '{ }');
            if (result) {
                location.reload();
            }
        }

        $scope.LoginInfo =
        {
            LoginId: "",
            Password: "",
            Remember: false
        };

        if (typeof (Storage) !== "undefined") {
            $scope.LoginInfo.LoginId = localStorage.getItem("SM_LoginId");
            $scope.LoginInfo.Password = localStorage.getItem("SM_Password");
            $scope.LoginInfo.Remember = localStorage.getItem("SM_Remember") == "true";
            if (window.location.href.toLowerCase().indexOf("/account/login?auto") >= 0) {
                if ($scope.LoginInfo.LoginId && $scope.LoginInfo.Password) {
                    var result = AjaxSync(g_loginUrl, '{ "loginId": "' + $scope.LoginInfo.LoginId + '", "password": "' + $scope.LoginInfo.Password + '"}');
                    if (result) {
                        location.reload();
                    }
                }
            }
        }

    }]);