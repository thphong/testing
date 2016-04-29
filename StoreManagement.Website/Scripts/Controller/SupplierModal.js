function CheckSupplierCodeUnique(value) {
    if (value) {
        var config = new ObjectDataConfig("T_Master_Suppliers", null);
        var object = config.GetObject(value, 'SupplierCode');
        if (object) {
            return false;
        }
    }
    return true;
}

mdlCommon.controller('SupplierModalController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {

        $scope.IsShowSupplierDetail = false;
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

        $scope.SupplierFormConfig = new ObjectDataConfig("T_Master_Suppliers", $scope);

        $scope.InitSupplier = function () {
            FValidation.ClearAllError();
            $scope.ResetSupplierForm();
        }


        $scope.SaveSupplierForm = function () {
            if (FValidation.CheckControls("check-supplier")) {
                $scope.SupplierFormConfig.SetObject($scope.SupplierForm);
                var supplierId = $scope.SupplierFormConfig.SaveObject();
                if (supplierId > 0) {
                    $scope.SupplierForm.SupplierId = supplierId;
                    $("button[data-dismiss='modal']:visible").click();
                    $scope.ReloadGrid('Suppliers');
                    ShowSuccessMessage("Nhà cung cấp được tạo thành công!");

                    $scope.ExposeFunctionAfterSavingSupplier();
                }
            }
        }

        $scope.DeleteSupplier = function (supplier) {
            if (confirm("Bạn có muốn xóa nhà cung cấp " + supplier.SupplierCode + " - " + supplier.SupplierName + "?")) {
                if ($scope.SupplierFormConfig.DeleteObject(supplier.SupplierId)) {
                    $scope.ReloadGrid('Suppliers');
                    ShowSuccessMessage("Nhà cung cấp được xóa thành công!");
                }
            }
        }

        $scope.ShowSupplierDetail = function (supplier) {

            var object = $scope.SupplierFormConfig.GetObject(supplier.SupplierCode, 'SupplierCode');
            $scope.SupplierFormConfig.CopyFields(object, $scope.SupplierForm);
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
        }

        $scope.ExposeFunctionAfterSavingSupplier = function () {
        }

    }]);