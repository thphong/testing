$(document).ready(function () {
    $('input.datepicker').datepicker({ format: 'dd-mm-yyyy'/*, startDate: '23-03-2016'*/ });
})


mdlCommon.controller('OrderController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.AdditionalFilter = {
            OrderType: "1",
            StartDate: "",
            EndDate: ""
        };


        $scope.OrderFormConfig = new ObjectDataConfig("T_Trans_Orders");

        $scope.DeleteOrder = function (order) {
            if (confirm("Bạn có muốn xóa đơn hàng " + order.OrderCode + "?")) {
                if ($scope.OrderFormConfig.DeleteObject(order.OrderCode, "OrderCode")) {
                    $scope.ReloadGrid('Orders');
                    ShowSuccessMessage("Đơn hàng được xóa thành công!");
                }
            }
        }

        /*$scope.IsShowSupplierDetail = false;
        $scope.IsEditingSupplierDetail = false;

        $scope.SupplierForm = {
            SupplierId: "-1",
            SupplierCode: "",
            SupplierName: "",
            Phone: "",
            Email: "",
            Address: "",
            TaxCode: "",
            Notes: "",
            IsActive: "1"
        };

        $scope.ResetSupplierForm = function () {
            $scope.SupplierForm.SupplierId = "-1";
            $scope.SupplierForm.SupplierCode = "";
            $scope.SupplierForm.SupplierName = "";
            $scope.SupplierForm.Phone = "";
            $scope.SupplierForm.Email = "";
            $scope.SupplierForm.TaxCode = "";
            $scope.SupplierForm.Notes = "";
            $scope.SupplierForm.Address = "";
        }

        $scope.InitSupplier = function () {
            FValidation.ClearAllError();
            $scope.ResetSupplierForm();
        }


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

        $scope.DeleteSupplier = function (supplier) {
            if (confirm("Bạn có muốn xóa nhà cung cấp " + supplier.SupplierCode + " - " + supplier.SupplierName + "?")) {
                if ($scope.SupplierFormConfig.DeleteObject(supplier.SupplierCode, "SupplierCode")) {
                    $scope.ReloadGrid('Suppliers');
                    ShowSuccessMessage("Nhà cung cấp được xóa thành công!");
                }
            }
        }

        $scope.ShowSupplierDetail = function (supplier) {

            var object = $scope.SupplierFormConfig.GetObject(supplier.SupplierCode, 'SupplierCode');
            $scope.SupplierFormConfig.ConvertFieldsToString(object, $scope.SupplierForm);
            $scope.IsShowSupplierDetail = true;
        }

        $scope.CloseSupplierDetail = function () {
            if ($scope.IsEditingSupplierDetail) {
                $scope.IsEditingSupplierDetail = false;
            }
            else {
                $scope.IsShowSupplierDetail = false;
            }
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