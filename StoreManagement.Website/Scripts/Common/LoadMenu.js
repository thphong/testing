angular.element(document).ready(function () {
    angular.bootstrap(document.getElementById('mdlMenu'), ['mdlMenu']);
    angular.bootstrap(document.getElementById('mdlCommon'), ['mdlCommon']);
});

mdlMenu.controller('LoadMenuController',
['$scope', '$filter', '$controller', '$interpolate', '$location', '$sce',
    function ($scope, $filter, $controller, $interpolate, $location, $sce) {
        //$controller('ctrlPaging', { $scope: $scope });

        $scope.CurrentStore = g_currentStoreId;
        $scope.CurrentUser = g_currentUserId;
        $scope.CurrentUrl = window.location.pathname.toLowerCase();
        $scope.CurrentUserName = g_currentUserName;
        $scope.StoreName = g_storeName;
        $scope.StoreAddress = g_storeAddress;
        $scope.StorePhone = g_storePhone;
        //$scope.Language = {
        //    Code: "VN",
        //    SelectedLanguage: "Tiếng Việt",
        //    Resource: gVNResource
        //};

        var configMenuList = new GridViewConfig("");
        configMenuList.GridDataAction = "getall";
        configMenuList.GridDataType = "function";
        configMenuList.GridDataObject = "dbo.UFN_System_Get_Menu";
        configMenuList.GridParametersExpression = "{{CurrentUser}}";
        configMenuList.OrderBy = "DisplayOrder";

        var configListStores = new GridViewConfig("");
        configListStores.GridDataAction = "getall";
        configListStores.GridDataType = "table";
        configListStores.GridDataObject = "T_Master_Stores";
        configListStores.GridDefinedColums = "StoreId;StoreName";
        configListStores.GridSortCondition = "StoreName ASC";
        configListStores.GridFilterCondition = "[IsActive] = 1";

        if ($scope.CurrentUser > 0) {
            configMenuList.EvaluateFieldExpression($interpolate, $scope);
            $scope.ListMenu = configMenuList.GetListData();

            $scope.ListStores = configListStores.GetListData();
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

        $scope.HasLoadFinished = false;
        $scope.LoadViewBody = function (url) {
            clearGlobalSession();
            $scope.CurrentUrl = url;
            var scope = angular.element(document.getElementById("mdlCommon")).scope();
            if (scope.SrcView != url) {
                $("i.img-loading").show();
                $("#bodyView").hide();
                scope.$apply(function () {
                    scope.SrcView = url;
                });
            }

            if (!$scope.HasLoadFinished) {
                scope.$on('$includeContentLoaded', function () {
                    $("i.img-loading").hide();
                    $("#bodyView").show();
                });
                $scope.HasLoadFinished = true;
            }
        }

        //$scope.ChangeLanguage = function (code) {
        //    if (code != $scope.Language.Code) {
        //        $scope.Language.Code = code;
        //        if (code == "VN") {
        //            $scope.Language.Resource = gVNResource;
        //            $scope.Language.SelectedLanguage = gVNResource.Vietnamese;
        //        }
        //        if (code == "EN") {
        //            $scope.Language.Resource = gENResource;
        //            $scope.Language.SelectedLanguage = gENResource.English;

        //        }

        //        var scope = angular.element($("#mdlCommon").find("[ng-controller]").first()).scope();
        //        if (scope) {
        //            scope.$apply(function () {
        //                scope.ChangeLanguage(code);
        //            });
        //        }
        //    }
        //}
        //$scope.ChangeLanguage(g_defaultLang);

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

        $(document).ready(function () {

            if (window.location.pathname.toLowerCase().indexOf("/account/posinfo") >= 0) {
                $("#linkUserInfo").click();
            }
            else {
                if ($("li.active a.left-menu").length > 0) {
                    $("li.active a.left-menu").first().click();
                }
                else {
                    $("a.left-menu").first().click();
                }
            }
        });

    }]);

