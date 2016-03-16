function CheckCustomerCodeUnique(value) {
    if (value) {
        var config = new ObjectDataConfig("T_Master_Customers");
        var object = config.GetObject(value, 'CustomerCode');
        if (object) {
            return false;
        }
    }
    return true;
}

function CheckSupplierCodeUnique(value) {
    if (value) {
        var config = new ObjectDataConfig("T_Master_Suppliers");
        var object = config.GetObject(value, 'SupplierCode');
        if (object) {
            return false;
        }
    }
    return true;
}

mdlCommon.controller('CustomerController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.AdditionalFilter = {
            CustomerType: "0",
            SaleCustomerType: "0",
            SupplierType: "0"
        };

        $scope.CurrentTab = "Customers";

        $scope.SetCurrentTab = function (tab) {
            if (tab != $scope.CurrentTab) {
                $scope.CurrentTab = tab;
                $scope.IsShowCustomerDetail = false;
                $scope.IsShowSupplierDetail = false;
            }
        }

        $scope.IsShowCustomerDetail = false;
        $scope.IsEditingCustomerDetail = false;

        $scope.CustomerForm = {
            CustomerId: "-1",
            CustomerCode: "",
            CustomerName: "",
            Phone: "",
            Address: "",
            Email: "",
            Notes: "",
            Birthday: "",
            IsWholeSale: "0",
            Gender: "M",
            IsActive: "1"
        };

        $scope.ResetCustomerForm = function () {
            $scope.CustomerForm.CustomerId = "-1";
            $scope.CustomerForm.CustomerCode = "";
            $scope.CustomerForm.CustomerName = "";
            $scope.CustomerForm.Phone = "";
            $scope.CustomerForm.Address = "";
            $scope.CustomerForm.Email = "";
            $scope.CustomerForm.Notes = "";
            $scope.CustomerForm.Birthday = "";
            $scope.CustomerForm.IsWholeSale = "0";
            $scope.CustomerForm.Gender = "M";
            $scope.CustomerForm.IsActive = "1";
        };


        $scope.CustomerFormConfig = new ObjectDataConfig("T_Master_Customers");
        $scope.SupplierFormConfig = new ObjectDataConfig("T_Master_Suppliers");

        $scope.SetIsSaleCustomer = function (sale) {
            FValidation.ClearAllError();
            $scope.ResetCustomerForm();
            $scope.CustomerForm.IsWholeSale = sale;
        }

        $scope.SaveCustomerForm = function () {
            if (FValidation.CheckControls("")) {
                $scope.CustomerFormConfig.SetObject($scope.CustomerForm);
                if ($scope.CustomerFormConfig.SaveObject()) {
                    $("button[data-dismiss='modal']:visible").click();

                    if ($scope.CustomerForm.IsWholeSale == '0') {
                        $scope.ReloadGrid('Customers');
                        ShowSuccessMessage("Khách hàng được tạo thành công!");
                    }
                    else {
                        $scope.ReloadGrid('SaleCustomers');
                        ShowSuccessMessage("Khách hàng sỉ được tạo thành công!");
                    }

                }
            }
        }

        $scope.DeleteCustomer = function (customer, isSale) {
            if (confirm("Bạn có muốn xóa khách hàng " + customer.CustomerCode + " - " + customer.CustomerName + "?")) {
                if ($scope.CustomerFormConfig.DeleteObject(customer.CustomerCode, "CustomerCode")) {
                    if (isSale == 0) {
                        $scope.ReloadGrid('Customers');
                        ShowSuccessMessage("Khách hàng được xóa thành công!");
                    }
                    else {
                        $scope.ReloadGrid('SaleCustomers');
                        ShowSuccessMessage("Khách hàng sỉ được xóa thành công!");
                    }
                }
            }
        }

        $scope.ShowCustomerDetail = function (customer) {

            var object = $scope.CustomerFormConfig.GetObject(customer.CustomerCode, 'CustomerCode');
            $scope.CustomerFormConfig.ConvertFieldsToString(object, $scope.CustomerForm);
            $scope.IsShowCustomerDetail = true;
            $scope.ReloadGrid('ListOrders');
        }

        $scope.CloseCustomerDetail = function () {
            if ($scope.IsEditingCustomerDetail) {
                $scope.IsEditingCustomerDetail = false;
            }
            else {
                $scope.IsShowCustomerDetail = false;
            }
        }

        $scope.EditCustomerDetail = function () {
            $scope.IsEditingCustomerDetail = true;
        }

        $scope.SaveCustomerDetail = function () {
            if (FValidation.CheckControls("")) {
                $scope.CustomerFormConfig.SetObject($scope.CustomerForm);
                if ($scope.CustomerFormConfig.SaveObject()) {
                    ShowSuccessMessage("Khách hàng được sửa thành công!");
                    $scope.IsEditingCustomerDetail = false;
                    $scope.ReloadGrid('Customers');
                }
            }
        }

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
        }

    }]);