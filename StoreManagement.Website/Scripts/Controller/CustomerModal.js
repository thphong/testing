function CheckCustomerCodeUnique(value) {
    if (value) {
        var config = new ObjectDataConfig("T_Master_Customers", null);
        var object = config.GetObject(value, 'CustomerCode');
        if (object) {
            return false;
        }
    }
    return true;
}


mdlCommon.controller('CustomerModalController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {

        $scope.IsShowCustomerDetail = false;
        $scope.IsEditingCustomerDetail = false;

        $scope.CustomerForm = {
            CustomerId: -1,
            CustomerCode: "",
            CustomerName: "",
            Phone: "",
            Address: "",
            Email: "",
            Notes: "",
            Birthday: "",
            IsWholeSale: 0,
            Gender: "M",
            IsActive: 1,
            _CanUpdate: true,
            _CanDelete: true,
            Version : 0
        };

        $scope.ResetCustomerForm = function () {
            $scope.CustomerForm.CustomerId = -1;
            $scope.CustomerForm.CustomerCode = "";
            $scope.CustomerForm.CustomerName = "";
            $scope.CustomerForm.Phone = "";
            $scope.CustomerForm.Address = "";
            $scope.CustomerForm.Email = "";
            $scope.CustomerForm.Notes = "";
            $scope.CustomerForm.Birthday = "";
            $scope.CustomerForm.IsWholeSale = 0;
            $scope.CustomerForm.Gender = "M";
            $scope.CustomerForm.IsActive = 1;
            $scope.CustomerForm._CanUpdate = 1;
            $scope.CustomerForm._CanDelete = 1;
            $scope.CustomerForm.Version = 0;
        };


        $scope.CustomerFormConfig = new ObjectDataConfig("T_Master_Customers", $scope);
        $scope.CustomerFormConfig.CheckCanCreateObject();

        $scope.SetIsSaleCustomer = function (sale) {
            FValidation.ClearAllError();
            $scope.ResetCustomerForm();
            $scope.CustomerForm.IsWholeSale = sale;
        }

        $scope.SaveCustomerForm = function () {
            if (FValidation.CheckControls("check-customer")) {
                $scope.CustomerFormConfig.SetObject($scope.CustomerForm);
                var customerId = $scope.CustomerFormConfig.SaveObject();
                if (customerId > 0) {
                    $scope.CustomerForm.CustomerId = customerId;
                    $("button[data-dismiss='modal']:visible").click();

                    if ($scope.CustomerForm.IsWholeSale == 0) {
                        $scope.ReloadGrid('Customers');
                        ShowSuccessMessage("Khách hàng được tạo thành công!");
                    }
                    else {
                        $scope.ReloadGrid('SaleCustomers');
                        ShowSuccessMessage("Khách hàng sỉ được tạo thành công!");
                    }

                    $scope.ExposeFunctionAfterSavingCustomer();
                }
            }
        }

        $scope.DeleteCustomer = function (customer, isSale) {
            if (confirm("Bạn có muốn xóa khách hàng " + customer.CustomerCode + " - " + customer.CustomerName + "?")) {
                if ($scope.CustomerFormConfig.DeleteObject(customer.CustomerId)) {
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
            $scope.CustomerFormConfig.CopyFields(object, $scope.CustomerForm);
            $scope.IsShowCustomerDetail = true;
            $scope.CustomerForm._CanUpdate = customer._CanUpdate;
            $scope.CustomerForm._CanDelete = customer._CanDelete;
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
                    //$scope.ReloadGrid('Customers');
                }
            }
        }

        $scope.ExposeFunctionAfterSavingCustomer = function () {
        }

    }]);