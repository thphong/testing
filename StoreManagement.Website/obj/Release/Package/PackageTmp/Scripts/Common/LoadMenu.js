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

        $scope.SetStoreId = function () {
            AjaxSync(g_setStoreIdUrl, '{ "storedId": ' + $scope.CurrentStore + '}');
            location.reload();
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
            ActionName: "",
            Action: "",
            Link: ""
        };

        $scope.ResetDataAction = function () {
            $scope.DataAction.ActionName = "";
            $scope.DataAction.Action = "";
            $scope.DataAction.Link = "";
        }

        $scope.SelectQuickAction = function () {
            var scope;
            switch ($scope.DataAction.Action) {
                case "LIST_ORDERS":
                    scope = angular.element(document.getElementById("OrderController")).scope();
                    scope.CloseOrderDetail();
                    break;
                case "ADD_ORDERS":
                    scope = angular.element(document.getElementById("OrderController")).scope();
                    scope.AddOrder();
                    break;
                case "LIST_CUSTOMERS":
                    scope = angular.element(document.getElementById("CustomerController")).scope();
                    scope.SetCurrentTab('Customers');
                    break;
                case "LIST_SALECUSTOMERS":
                    scope = angular.element(document.getElementById("CustomerController")).scope();
                    scope.SetCurrentTab('SaleCustomers');
                    break;
                case "LIST_SUPPLIER":
                    scope = angular.element(document.getElementById("CustomerController")).scope();
                    scope.SetCurrentTab('Suppliers');
                    break;
                case "LIST_PURCHASE":
                    scope = angular.element(document.getElementById("PurchaseController")).scope();
                    scope.ClosePurchaseDetail();
                    break;
                case "ADD_PURCHASE":
                    scope = angular.element(document.getElementById("PurchaseController")).scope();
                    scope.AddPurchase();
                    break;
                case "LIST_PRODUCTS":
                    scope = angular.element(document.getElementById("ProductController")).scope();
                    scope.SetCurrentTab('Products');
                    scope.CloseProductDetail();
                    break;
                case "ADD_PRODUCTS":
                    scope = angular.element(document.getElementById("ProductController")).scope();
                    scope.SetCurrentTab('Products');
                    scope.AddProduct(0);
                    break;
                case "LIST_COMBO":
                    scope = angular.element(document.getElementById("ProductController")).scope();
                    scope.SetCurrentTab('Combos');
                    scope.CloseProductDetail()
                    break;
                case "ADD_COMBO":
                    scope = angular.element(document.getElementById("ProductController")).scope();
                    scope.SetCurrentTab('Combos');
                    scope.AddProduct(1);
                    break;
                case "INVENTORY":
                    scope = angular.element(document.getElementById("InventoryController")).scope();
                    scope.SetCurrentTab('InventoryProduct');
                    break;
                case "INVENTORY_INOUT":
                    scope = angular.element(document.getElementById("InventoryController")).scope();
                    scope.SetCurrentTab('InventoryInOut');
                    break;
                case "INVENTORY_CHECK":
                    scope = angular.element(document.getElementById("InventoryController")).scope();
                    scope.SetCurrentTab('InventoryCheck');
                    scope.CloseInventoryDetail();
                    break;
                case "INVENTORY_TRAN":
                    scope = angular.element(document.getElementById("InventoryController")).scope();
                    scope.SetCurrentTab('InventTrans');
                    scope.CloseInventTranDetail();
                    break;
                case "ADD_INVENTORY_CHECK":
                    scope = angular.element(document.getElementById("InventoryController")).scope();
                    scope.SetCurrentTab('InventoryCheck');
                    scope.AddInventory();
                    break;
                case "ADD_INVENTORY_TRAN":
                    scope = angular.element(document.getElementById("InventoryController")).scope();
                    scope.SetCurrentTab('InventTrans');
                    scope.AddInventTran();
                    break;
                case "REVENUE_BY_SELLER":
                    scope = angular.element(document.getElementById("RevenueController")).scope();
                    scope.SetCurrentTab('ReportBySeller');
                    break;
                case "REVENUE_BY_STORE":
                    scope = angular.element(document.getElementById("RevenueController")).scope();
                    scope.SetCurrentTab('ReportByStore');
                    break;
                case "REVENUE_BY_MONTH":
                    scope = angular.element(document.getElementById("RevenueController")).scope();
                    scope.SetCurrentTab('ReportByMonth');
                    break;
                case "REVENUE_BY_PRODUCT":
                    scope = angular.element(document.getElementById("RevenueController")).scope();
                    scope.SetCurrentTab('ReportByProduct');
                    break;
                case "PAYMENT":
                    scope = angular.element(document.getElementById("PaymentController")).scope();
                    scope.SetCurrentTab('Costs');
                    break;
                case "PAYMENT_ORDER":
                    scope = angular.element(document.getElementById("PaymentController")).scope();
                    scope.SetCurrentTab('Payments');
                    break;
                case "RECEIVEMENT":
                    var scope = angular.element(document.getElementById("PaymentController")).scope();
                    scope.SetCurrentTab('CollectMoneys');
                    break;
                case "PROFIT_BY_TIME":
                    scope = angular.element(document.getElementById("ProfitController")).scope();
                    scope.SetCurrentTab('ReportByTime');
                    break;
                case "PROFIT_BY_PRODUCT":
                    scope = angular.element(document.getElementById("ProfitController")).scope();
                    scope.SetCurrentTab('ReportByProduct');
                    break;
                case "PROFIT_BY_STORE":
                    scope = angular.element(document.getElementById("ProfitController")).scope();
                    scope.SetCurrentTab('ReportByStore');
                    break;
                case "PROFIT_SUMMARY":
                    scope = angular.element(document.getElementById("ProfitController")).scope();
                    scope.SetCurrentTab('ReportProfit');
                    break;
                case "SETTING_USER":
                    scope = angular.element(document.getElementById("SettingController")).scope();
                    scope.SetCurrentTab('Users');
                    break;
                case "SETTING_STORE":
                    scope = angular.element(document.getElementById("SettingController")).scope();
                    scope.SetCurrentTab('Stores');
                    break;
                case "SETTING_CONFIG":
                    scope = angular.element(document.getElementById("SettingController")).scope();
                    scope.SetCurrentTab('Setting');
                    break;
                case "SETTING_PRINT":
                    scope = angular.element(document.getElementById("SettingController")).scope();
                    scope.SetCurrentTab('Prints');
                    break;
                case "SETTING_PROMOTION":
                    scope = angular.element(document.getElementById("SettingController")).scope();
                    scope.SetCurrentTab('Promotion');
                    break;
            }
            scope.$apply();
        }

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
                    $scope.SelectQuickAction();
                });
                $scope.HasLoadFinished = true;
            }
        }
                
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
                    ShowErrorMessage("Bạn không có quyền truy cập chức năng này.");
                }
                else {
                    $scope.LoadViewBody(newVal);
                }
            }
        }, false);


        $scope.$watch('DataAction.Action', function (newVal, oldVal) {
            if (newVal) {
                if ($scope.CurrentUrl == $scope.DataAction.Link || $scope.DataAction.Link == "") {
                    $scope.SelectQuickAction();
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

