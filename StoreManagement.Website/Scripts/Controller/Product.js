function CheckProductCodeUnique(value) {
    if (value) {
        var config = new ObjectDataConfig("T_Trans_Products");
        var object = config.GetObject(value, 'ProductCode');
        if (object) {
            return false;
        }
    }
    return true;
}

mdlCommon.controller('ProductController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.AdditionalFilter = {
            ProductStatus: "1",
            ProductGroup: "0",
            Producer: "0"
        };

        $scope.IsShowProductDetail = false;
        $scope.IsEditingProductDetail = false;

        $scope.ProductForm = {
            ProductId: "-1",
            ProductCode: "",
            ProductName: "",
            Quantity: "0",
            TrackInventory: "1",
            AllowNegative: "1",
            Cost: "0",
            Price: "0",
            ProductGroup: "",
            ProducerId: "",
            VAT: "0",
            IsSelling: "1",
            IsActive: "1",
            AllowMin: "0",
            AllowMax: "100",
            IsManageAsSerial: "0",
            IsManageAttribute: "0",
            Description: ""
        };

        $scope.ResetProductForm = function () {
            $scope.ProductForm.ProductId = "-1";
            $scope.ProductForm.ProductCode = "";
            $scope.ProductForm.ProductName = "";
            $scope.ProductForm.TrackInventory = "1";
            $scope.ProductForm.AllowNegative = "1";
            $scope.ProductForm.Cost = "0";
            $scope.ProductForm.Price = "0";
            $scope.ProductForm.ProductGroup = "";
            $scope.ProductForm.ProducerId = "";
            $scope.ProductForm.VAT = "0";
            $scope.ProductForm.IsSelling = "1";
            $scope.ProductForm.IsActive = "1";
            $scope.ProductForm.AllowMin = "0";
            $scope.ProductForm.AllowMax = "100";
            $scope.ProductForm.IsManageAsSerial = "0";
            $scope.ProductForm.IsManageAttribute = "0";
            $scope.ProductForm.Description = "";
        };

        $scope.ProductFormConfig = new ObjectDataConfig("T_Trans_Products");

        $scope.DeleteProduct = function (product) {
            if (confirm("Bạn có muốn xóa hàng hóa " + product.ProductCode + " - " + product.ProductName + "?")) {
                if ($scope.ProductFormConfig.DeleteObject(product.ProductId)) {
                    $scope.ReloadGrid('Products');
                    ShowSuccessMessage("Hàng hóa được xóa thành công!");
                }
            }
        }

        $scope.StopSellingProduct = function (product) {
            if (confirm("Bạn có muốn ngừng kinh doanh hàng hóa " + product.ProductCode + " - " + product.ProductName + "?")) {

                $scope.ProductFormConfig.SetObject({ "ProductId": product.ProductId, "IsSelling": 0 });
                if ($scope.ProductFormConfig.SaveObject()) {
                    $scope.ReloadGrid('Products');
                    ShowSuccessMessage("Nhưng kinh doanh hàng " + product.ProductCode + " - " + product.ProductName + " thành công!");
                }
            }
        }

        $scope.EnableSellingProduct = function (product) {
            if (confirm("Bạn có muốn cho phép kinh doanh hàng hóa " + product.ProductCode + " - " + product.ProductName + "?")) {
                $scope.ProductFormConfig.SetObject({ "ProductId": product.ProductId, "IsSelling": 1 });
                if ($scope.ProductFormConfig.SaveObject()) {
                    $scope.ReloadGrid('Products');
                    ShowSuccessMessage("Cho phép kinh doanh hàng " + product.ProductCode + " - " + product.ProductName + " thành công!");
                }
            }
        }

        $scope.AddProduct = function () {
            $scope.IsShowProductDetail = true;
            $scope.IsEditingProductDetail = true;
            $scope.ResetProductForm();
        }

        $scope.CloseProductDetail = function () {
            if ($scope.IsEditingProductDetail && $scope.ProductForm.ProductId != "-1") {
                $scope.IsEditingProductDetail = false;
            }
            else {
                $scope.IsShowProductDetail = false;
            }
        }

        $scope.ChangeTrackInventory = function () {
            if ($scope.ProductForm.TrackInventory == '0')
            {
                $scope.ProductForm.AllowNegative = '0';
            }
        }

        $scope.ChangeIsManageAsSerial = function () {
            if ($scope.ProductForm.IsManageAsSerial == '1') {
                $scope.ProductForm.TrackInventory = '1';
                $scope.ProductForm.AllowNegative = '0';
            }
        }

        $scope.SaveProductForm = function (isContinue) {
            if (FValidation.CheckControls("")) {
                $scope.ProductFormConfig.SetObject($scope.ProductForm);
                if ($scope.ProductFormConfig.SaveObject()) {
                    if (isContinue) {
                        $scope.ResetProductForm();
                    }
                    else {
                        $scope.ReloadGrid('Products');
                        $scope.IsEditingProductDetail = false;
                        $scope.IsShowProductDetail = false;
                    }
                    ShowSuccessMessage("Hàng hóa được tạo thành công!");
                }
            }
        }

        $scope.CopyProduct = function (product) {
            var object = $scope.ProductFormConfig.GetObject(product.ProductId);
            $scope.ProductFormConfig.ConvertFieldsToString(object, $scope.ProductForm);
            $scope.ProductForm.ProductName = $scope.ProductForm.ProductName + " - Copy";
            $scope.ProductForm.ProductCode = "";
            $scope.ProductForm.ProductId = -1;
            $scope.ProductForm.Cost = $filter('currency')($scope.ProductForm.Cost, "", 0);
            $scope.ProductForm.Price = $filter('currency')($scope.ProductForm.Price, "", 0);

            $scope.IsShowProductDetail = true;
            $scope.IsEditingProductDetail = true;
        }
        /*
        
        $scope.ShowCustomerDetail = function (customer) {

            var object = $scope.CustomerFormConfig.GetObject(customer.CustomerCode, 'CustomerCode');
            $scope.CustomerFormConfig.ConvertFieldsToString(object, $scope.CustomerForm);
            $scope.IsShowCustomerDetail = true;
            $scope.ReloadGrid('ListOrders');
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
        }*/
    }]);