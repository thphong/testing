angular.element(document).ready(function () {
    angular.bootstrap(document.getElementById('mdlMenu'), ['mdlMenu']);
    angular.bootstrap(document.getElementById('mdlCommon'), ['mdlCommon']);
});

//Control for auto complete
mdlMenu.directive('autocompleteMasterTable', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {

        var autocompleteId = "autocompleteId" + parseInt(Math.random() * 1000000);
        element.attr("autocomplete-id", autocompleteId);
        element.after('<span ng-init="InitAutoComplete(\'' + autocompleteId + '\');"></span>');

    }
    return directive;
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
        configListStores.GridDataAction = "get10";
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

        $scope.DataAction =
        {
            Action: "",
            Link: ""
        };

        $scope.HasLoadFinished = false;
        $scope.LoadViewBody = function (url) {
            clearGlobalSession();
            $scope.CurrentUrl = url;
            $("[data-toggle='collapse']:visible").click();
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

        $scope.InitListAutoCompleteStores = function (elementId) {
            $(elementId).autocomplete({
                minLength: 0,
                source: function (request, response) {
                    var configList = new GridViewConfig("");
                    configList.GridDataAction = "get10";
                    configList.GridDataType = "table";
                    configList.GridDataObject = "T_Master_Stores";
                    configList.GridDefinedColums = "StoreId;StoreCode;StoreName";
                    configList.GridSortCondition = "StoreName ASC";
                    configList.GridFilterCondition = "[IsActive] = 1 AND (StoreCode like N''%" + request.term + "%''  OR StoreName like N''%" + request.term + "%'' )";

                    var listData = configList.GetListData();
                    if (listData.length > 0) {
                        response(listData);
                    }
                    else {
                        response(["Không tìm thấy kết quả"]);
                    }
                },
                focus: function (event, ui) {
                    $(elementId).val( ui.item.StoreName);
                    return false;
                },
                select: function (event, ui) {
                    if (ui.item.StoreCode) {
                        $scope.SetStoreId(ui.item.StoreId);
                    }
                    return false;
                }
            })
            .autocomplete("instance")._renderItem = function (ul, item) {
                var content;
                if (item.StoreCode) {
                    content = "<a> <b>" + item.StoreName + " </b><br/> </a>";
                }
                else {
                    content = "<a>" + item.label + "</a>";
                }
                return $("<li>")
                        .append(content)
                        .appendTo(ul);
            };
        }


        $scope.InitAutoComplete = function (autocompleteId) {
            var element = $('input[autocomplete-id="' + autocompleteId + '"]');
            element.autocomplete({
                minLength: 0,
                source: function (request, response) {
                    var configList = new GridViewConfig("");
                    configList.GridDataAction = "get10";
                    configList.GridDataObject = element.attr("autocomplete-master-table");
                    configList.GridDefinedColums = element.attr("autocomplete-colum-id") + ";" + element.attr("autocomplete-colum-name");
                    configList.GridFilterCondition = element.attr("autocomplete-colum-name") + " like N''%" + request.term + "%''";
                    if (element.attr("autocomplete-colum-code")) {
                        configList.GridDefinedColums += ";" + element.attr("autocomplete-colum-code");
                        configList.GridSortCondition = element.attr("autocomplete-colum-code") + " ASC";
                        configList.GridFilterCondition += " or " + element.attr("autocomplete-colum-code") + " like N''%" + request.term + "%''";
                    }
                    else {
                        configList.GridSortCondition = element.attr("autocomplete-colum-name") + " ASC";
                    }
                    if (element.attr("autocomplete-condition")) {
                        configList.GridFilterCondition = element.attr("autocomplete-condition") + " and (" + configList.GridFilterCondition + ")";
                    }
                    if (element.attr("autocomplete-colum-additional")) {
                        configList.GridDefinedColums += ";" + element.attr("autocomplete-colum-additional");
                    }

                    var listData = configList.GetListData();
                    if (listData.length > 0) {
                        response(listData);
                    }
                    else {
                        response(["Không tìm thấy kết quả"]);
                    }
                },
                focus: function (event, ui) {
                    if (ui.item[element.attr("autocomplete-colum-id")]) {
                        $(element).val(ui.item[element.attr("autocomplete-colum-name")]);
                        }
                    return false;
                },
                select: function (event, ui) {
                    if (ui.item[element.attr("autocomplete-colum-id")]) {
                        $(element).val(ui.item[element.attr("autocomplete-colum-name")]);
                        $(element.attr("autocomplete-model-id")).val(ui.item[element.attr("autocomplete-colum-id")]).change();
                        if (element.attr("autocomplete-model-additional")) {
                            $(element.attr("autocomplete-model-additional")).val(ui.item[element.attr("autocomplete-colum-additional")]).change();
                        }
                    }
                    return false;
                }
            })
            .autocomplete("instance")._renderItem = function (ul, item) {
                var content;
                if (item[element.attr("autocomplete-colum-code")]) {
                    content = "<a> <b>" + item[element.attr("autocomplete-colum-code")] + " </b><br>" + item[element.attr("autocomplete-colum-name")] + "</a>";
                }
                else if (item[element.attr("autocomplete-colum-name")]) {
                    content = "<a>" + item[element.attr("autocomplete-colum-name")] + "</a>";
                }
                else {
                    content = "<a>" + item.label + "</a>";
                }

                return $("<li>")
                        .append(content)
                        .appendTo(ul);
            };
        }

        
        $scope.$watch('DataAction.Link', function (newVal, oldVal) {
            if (newVal) {
                var a = $("a.left-menu[action='" + newVal + "']");
                if (a.length == 0) {
                    alert('Ban khong co quyen truy cap chuc nang nay?');
                }
                else {
                    $scope.LoadViewBody(newVal);
                }
            }
        }, false);

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

