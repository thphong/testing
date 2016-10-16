mdlCommon.controller('ManageStoreController',
['$scope', '$filter', '$controller', '$interpolate', '$sce',
    function ($scope, $filter, $controller, $interpolate, $sce) {
        $controller('ctrlPaging', { $scope: $scope });

        //General info
        $scope.ConfigList = new GridViewConfig("");
        $scope.ConfigList.GridDataAction = "getall";
        $scope.ConfigList.GridDataType = "function";
        $scope.ConfigList.GridDataObject = "dbo.UFN_Report_General";
        $scope.ConfigList.GridDefinedColums = "Revenue;NumOrder;NumSoldProduct;ReturnAmount;LongInventory;OutOfQuantity;UnderMin;OverMax;TotalProduct;NotInputPrice;NotInputCost;NotInputGroup";
        $scope.ConfigList.GridParameters = $scope.CurrentUser + "," + $scope.CurrentStore;

        $scope.GeneralInfo = $scope.ConfigList.GetListData()[0];

        //Chart
        $scope.SetFilterRangeDate(1, "");
        $scope.ConfigList.GridDataObject = "dbo.UFN_Report_Revenue_By_Day";
        $scope.ConfigList.GridDefinedColums = "Day;Revenue;LastRevenue";
        $scope.ConfigList.GridParametersExpression = "{{CurrentUser}},dbo.UFN_System_GetDateTime(''{{FilterRangeDate.StartDate}}'', ''dd-MM-yyyy''),dbo.UFN_System_GetDateTime(''{{FilterRangeDate.EndDate}}'', ''dd-MM-yyyy''), {{CurrentStore}}";

        //Revenue in week
        $scope.ConfigList.GridDataObject = "dbo.UFN_Report_Profit_By_Store";
        $scope.ConfigList.GridDefinedColums = "Quantity;Revenue;ReturnAmount;Cost;Profit";
        $scope.ConfigList.GridParametersExpression = "{{CurrentUser}},dbo.UFN_System_GetDateTime(''{{FilterRangeDate.StartDate}}'', ''dd-MM-yyyy''),dbo.UFN_System_GetDateTime(''{{FilterRangeDate.EndDate}}'', ''dd-MM-yyyy''), {{CurrentStore}}";

        $scope.AdditionalFilter =
        {
            StoreStatus: "1",
            PaymentType: "0"
        };

        $scope.ExtendForm = {
            StoreId: -1,
            Amount: "",
            Payer: "",
            NumMonth: "",
            PaymentType: "1",
            Description: "",
            IsActive: 1,
            Version: 0
        };

        $scope.ResetExtendForm = function () {
            $scope.ExtendForm.StoreId = -1;
            $scope.ExtendForm.Amount = "";
            $scope.ExtendForm.Payer = "";
            $scope.ExtendForm.NumMonth = "";
            $scope.ExtendForm.PaymentType = "1";
            $scope.ExtendForm.Description = "";
            $scope.ExtendForm.IsActive = 1;
            $scope.ExtendForm.Version = 0;
        };

        $scope.ExtendFormConfig = new ObjectDataConfig("T_Trans_StoreActivation", $scope);
        $scope.StoreFormConfig = new ObjectDataConfig("T_Master_Stores", $scope);

        $scope.OpenExtendStore = function (storeId) {
            $scope.ExtendForm.StoreId = storeId;
        }

        $scope.SaveExtendForm = function () {
            if (FValidation.CheckControls()) {
                $scope.ExtendFormConfig.SetObject($scope.ExtendForm);
                var Id = $scope.ExtendFormConfig.SaveObject();
                if (Id > 0) {
                    $("button[data-dismiss='modal']:visible").click();
                    ShowSuccessMessage("Cửa hàng được kích hoạt thành công!");
                    $scope.ReloadGrid('Stores');
                    $scope.ReloadGrid('Revenue');
                    $scope.ResetExtendForm();
                }
            }
        }

        $scope.DeactivateStore = function (store) {
            if (confirm("Bạn có muốn ngừng hoạt động cửa hàng " + store.StoreName + "?")) {
                $scope.StoreFormConfig.SetObject({ "StoreId": store.StoreId, "IsActive": 0, "Version": store.Version });
                var storeId = $scope.StoreFormConfig.SaveObject();
                if (storeId > 0) {
                    ShowSuccessMessage("Cửa hàng đã ngừng hoạt động!");
                    $scope.ReloadGrid('Stores');
                }
            }
        }

    }]);