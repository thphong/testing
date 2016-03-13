mdlCommon.controller('RootController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.Form = {
            OrderId: "",
            OrderCode: "",
            StoreId: "0",
            SoldDate: "",
            Cashier: "0",
            Customer: "0",
            OrderStatus: "0",
            SumMoney: "0",
            DebtMoney: "0",
            IsActive: "1"
        };

        $scope.FormConfig = new ObjectDataConfig("T_Trans_Orders");

        $scope.SaveForm = function () {
            if (FValidation.CheckControls("")) {                
                $scope.FormConfig.SetObject($scope.Form);
                $scope.FormConfig.SaveObject();
            }
        }

        $scope.ClickOnItem = function (item) {
            $scope.FormConfig.ConvertFieldsToString(item, $scope.Form);
        }

        $scope.ResetForm = function () {
            $scope.Form.OrderId = "";
            $scope.Form.OrderCode = "";
            $scope.Form.StoreId = "0";
            $scope.Form.SoldDate = "";
            $scope.Form.Cashier = "0";
            $scope.Form.Customer = "0";
            $scope.Form.OrderStatus = "0";
            $scope.Form.SumMoney = "0";
            $scope.Form.DebtMoney = "0";
            $scope.Form.IsActive = "1";
        }

        $scope.ShowMessage = function () {
            ShowErrorMessage("Bạn đã lưu dữ liệu thành công!");
        }

        /*$scope.ExportExcel = function (gridView) {
            gridView.ExportDataToExcel();
        }*/

    }]);