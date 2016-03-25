$(document).ready(function () {
    $('input.datepicker').datepicker({ format: 'dd-mm-yyyy'/*, startDate: '23-03-2016'*/ });
})


mdlCommon.controller('OrderController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('CustomerModalController', { $scope: $scope });

        $scope.AdditionalFilter = {
            OrderType: "1",
            StartDate: "",
            EndDate: "",
            Status: "0"
        };

        $scope.RangeDate = 0;
        $scope.SetRangeDate = function (option) {

            var curr = new Date(); // get current date
            var first = curr.getDate() - curr.getDay() + 1; // First day is the day of the month - the day of the week
            var last = first + 6; // last day is the first day + 6
            var y = curr.getFullYear(), m = curr.getMonth();
            var quarter = Math.floor(curr.getMonth() / 3);

            switch (option) {
                case 1: //This week
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(curr.setDate(first)));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(curr.setDate(last)));
                    break;
                case 2: //This month
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(y, m, 1));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(y, m + 1, 0));
                    break;
                case 3: //This quarter
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(y, quarter * 3, 1));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(y, quarter * 3 + 3, 0));
                    break;
                case 4: //last week
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(curr.setDate(first - 7)));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(curr.setDate(last - 7)));
                    break;
                case 5: //Last month
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(y, m - 1, 1));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(y, m, 0));
                    break;
                case 6: //Last quarter
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(y, (quarter -1) * 3, 1));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(y, quarter * 3, 0));
                    break;
            }
            $scope.RangeDate = option;
            $scope.ReloadGrid('Orders');
        }

        $scope.OrderFormConfig = new ObjectDataConfig("T_Trans_Orders");

        $scope.DeleteOrder = function (order) {
            if (confirm("Bạn có muốn xóa đơn hàng " + order.OrderCode + "?")) {
                if ($scope.OrderFormConfig.DeleteObject(order.OrderCode, "OrderCode")) {
                    $scope.ReloadGrid('Orders');
                    ShowSuccessMessage("Đơn hàng được xóa thành công!");
                }
            }
        }

        $scope.IsShowOrderDetail = false;
        $scope.IsEditingOrderDetail = false;

        $scope.OrderForm = {
            OrderId: "-1"
        };

        $scope.ResetOrderForm = function () {
            $scope.OrderForm.OrderId = "-1";
        }

        $scope.AddOrder = function () {
            $scope.IsShowOrderDetail = true;
            $scope.IsEditingOrderDetail = true;
            FValidation.ClearAllError();
            $scope.ResetOrderForm();
        }

        $scope.CloseOrderDetail = function () {
            if ($scope.IsEditingOrderDetail && $scope.OrderForm.OrderId != "-1") {
                $scope.IsEditingOrderDetail = false;
            }
            else {
                $scope.IsShowOrderDetail = false;
            }
        }

        /*
        $scope.SaveSupplierForm = function () {
            if (FValidation.CheckControls("")) {
                $scope.SupplierFormConfig.SetObject($scope.SupplierForm);
                if ($scope.SupplierFormConfig.SaveObject()) {
                    $("button[data-dismiss='modal']:visible").click();
                    $scope.ReloadGrid('Suppliers');
                    ShowSuccessMessage("Nhà cung cấp được tạo thành công!");

                }
            }
        }

        $scope.ShowSupplierDetail = function (supplier) {

            var object = $scope.SupplierFormConfig.GetObject(supplier.SupplierCode, 'SupplierCode');
            $scope.SupplierFormConfig.ConvertFieldsToString(object, $scope.SupplierForm);
            $scope.IsShowSupplierDetail = true;
        }

        $scope.EditSupplierDetail = function () {
            $scope.IsEditingSupplierDetail = true;
        }

        $scope.SaveSupplierDetail = function () {
            if (FValidation.CheckControls("")) {
                $scope.SupplierFormConfig.SetObject($scope.SupplierForm);
                if ($scope.SupplierFormConfig.SaveObject()) {
                    ShowSuccessMessage("Nhà cung cấp được sửa thành công!");
                    $scope.IsEditingSupplierDetail = false;
                    $scope.ReloadGrid('Suppliers');
                }
            }
        }*/

    }]);