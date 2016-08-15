function CheckProductCodeUnique(value) {
    if (value) {
        var config = new ObjectDataConfig("T_Trans_Products", null);
        var object = config.GetObject(value, 'ProductCode');
        if (object) {
            return false;
        }
    }
    return true;
}

function CheckNumOfProductCombo() {
    var scope = angular.element(document.getElementById("ProductController")).scope();
    var len = scope.DataSet.ProductChildren.Data.length;
    return len > 0;
}

mdlCommon.controller('ProductController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('ProductGroupController', { $scope: $scope });
        $controller('ProducerController', { $scope: $scope });
        $controller('AttributeController', { $scope: $scope });
        $controller('ProductQuanHistoryController', { $scope: $scope });
        $controller('ProductListController', { $scope: $scope });

        $scope.CurrentTab = "Products";

        $scope.SetCurrentTab = function (tab) {
            if (tab != $scope.CurrentTab) {
                $scope.CurrentTab = tab;
                $scope.IsShowProductDetail = false;
            }
        }

        $scope.AdditionalFilter = {
            ProductStatus: "1",
            ProductGroup: "0",
            Producer: "0",
            ProductType: "0"
        };

        $scope.IsShowProductDetail = false;
        $scope.IsEditingProductDetail = false;

        $scope.ProductForm = {
            OldProductId: -1,
            ProductId: -1,
            ProductCode: "",
            ProductName: "",
            Quantity: 0,
            TrackInventory: 1,
            AllowNegative: 0,
            Cost: 0,
            Price: 0,
            SumPriceInCombo: 0,
            ProductGroup: "",
            ProducerId: "",
            VAT: "0",
            IsSelling: 1,
            IsActive: 1,
            AllowMin: 0,
            AllowMax: 100,
            IsManageAsSerial: 0,
            IsManageAttribute: 0,
            Description: "",
            ProductGroupName: "",
            ProducerName: "",
            IsCost: 0,
            LastReferNo: "",
            LastComment: "",
            Version: 0,
            isCombo: 0,
            _CanUpdate: true,
            _CanDelete: true
        };

        $scope.ResetProductForm = function () {
            $scope.ProductForm.OldProductId = -1;
            $scope.ProductForm.ProductId = -1;
            $scope.ProductForm.ProductCode = "";
            $scope.ProductForm.ProductName = "";
            $scope.ProductForm.TrackInventory = 1;
            $scope.ProductForm.AllowNegative = 0;
            $scope.ProductForm.Cost = 0;
            $scope.ProductForm.Price = 0;
            $scope.ProductForm.SumPriceInCombo = 0;
            $scope.ProductForm.ProductGroup = "";
            $scope.ProductForm.ProducerId = "";
            $scope.ProductForm.VAT = "0";
            $scope.ProductForm.IsSelling = 1;
            $scope.ProductForm.IsActive = 1;
            $scope.ProductForm.AllowMin = 0;
            $scope.ProductForm.AllowMax = 100;
            $scope.ProductForm.Quantity = 0;
            $scope.ProductForm.IsManageAsSerial = 0;
            $scope.ProductForm.IsManageAttribute = 0;
            $scope.ProductForm.Description = "";
            $scope.ProductForm.ProductGroupName = "";
            $scope.ProductForm.ProducerName = "";
            $scope.ProductForm.IsCost = 0;
            $scope.ProductForm.LastReferNo = "";
            $scope.ProductForm.LastComment = "";
            $scope.ProductForm._CanUpdate = true;
            $scope.ProductForm._CanDelete = true;
            $scope.ProductForm.Version = 0;
            $scope.ProductForm.isCombo = 0;
        };

        $scope.ProductFormConfig = new ObjectDataConfig("T_Trans_Products", $scope);
        $scope.ProductAttributeFormConfig = new ObjectDataConfig("T_Trans_Product_Attribute", $scope);
        $scope.ProductComboFormConfig = new ObjectDataConfig("T_Trans_Combo_Products", $scope);
        
        $scope.ProductFormConfig.CheckCanCreateObject();
        $scope.CanViewPrice = $scope.ProductFormConfig.CheckField('PRODUCT_PRICE');

        $scope.IsShownPriceHisModal = false;
        $scope.SetShownPriceHisModal = function (isShown) {
            $scope.IsShownPriceHisModal = isShown;
        }

        $scope.DeleteProduct = function (product) {
            if (confirm("Bạn có muốn xóa hàng hóa " + product.ProductCode + " - " + product.ProductName + "?")) {
                if ($scope.ProductFormConfig.DeleteObject(product.ProductId)) {
                    if ($scope.CurrentTab == "Products") {
                        $scope.ReloadGrid('Products');
                    }
                    else {
                        $scope.ReloadGrid('Combos');
                    }
                    product.IsActive = 0;
                    ShowSuccessMessage("Hàng hóa được xóa thành công!");
                }
            }
        }

        $scope.StopSellingProduct = function (product) {
            if (confirm("Bạn có muốn ngừng kinh doanh hàng hóa " + product.ProductCode + " - " + product.ProductName + "?")) {
                $scope.ProductFormConfig.SetObject({ "ProductId": product.ProductId, "IsSelling": "0", "version": product.ProductVersion });
                if ($scope.ProductFormConfig.SaveObject()) {
                    if ($scope.CurrentTab == "Products") {
                        $scope.ReloadGrid('Products');
                    }
                    else {
                        $scope.ReloadGrid('Combos');
                    }
                    product.IsSelling = 0;
                    ShowSuccessMessage("Nhưng kinh doanh hàng " + product.ProductCode + " - " + product.ProductName + " thành công!");
                }
            }
        }

        $scope.EnableSellingProduct = function (product) {
            if (confirm("Bạn có muốn cho phép kinh doanh hàng hóa " + product.ProductCode + " - " + product.ProductName + "?")) {
                $scope.ProductFormConfig.SetObject({ "ProductId": product.ProductId, "IsSelling": "1", "version": product.ProductVersion });
                if ($scope.ProductFormConfig.SaveObject()) {
                    if ($scope.CurrentTab == "Products") {
                        $scope.ReloadGrid('Products');
                    }
                    else {
                        $scope.ReloadGrid('Combos');
                    }
                    product.IsSelling = 1;
                    ShowSuccessMessage("Cho phép kinh doanh hàng " + product.ProductCode + " - " + product.ProductName + " thành công!");
                }
            }
        }

        $scope.AddProduct = function (isCombo) {
            $scope.IsShowProductDetail = true;
            $scope.IsEditingProductDetail = true;
            FValidation.ClearAllError();
            $scope.ResetProductForm();
            $scope.ProductForm.isCombo = isCombo;
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
            if ($scope.ProductForm.TrackInventory == 0) {
                $scope.ProductForm.AllowNegative = 0;
            }
        }

        $scope.ChangeIsManageAsSerial = function () {
            if ($scope.ProductForm.IsManageAsSerial == 1) {
                $scope.ProductForm.TrackInventory = 1;
                $scope.ProductForm.AllowNegative = 0;
            }
        }

        $scope.SaveProductForm = function (isContinue) {

            if (FValidation.CheckControls("")) {
                $scope.ProductFormConfig.SetObject($scope.ProductForm);

                if ($scope.CurrentTab == "Products") {
                    $scope.ProductFormConfig.SetSubTableName("T_Trans_Product_Attribute");
                    $scope.ProductFormConfig.SetListObject($scope.DataSet.ProductAttributes.Data);
                }
                else if ($scope.CurrentTab == "Combos") {
                    $scope.ProductFormConfig.SetSubTableName("T_Trans_Combo_Products");
                    $scope.ProductFormConfig.SetListObject($scope.DataSet.ProductChildren.Data);
                }

                var productId = $scope.ProductFormConfig.SaveComplexObject();
                if (productId > 0) {
                    if ($scope.ProductForm.ProductId != -1) {

                        $scope.ProductForm.ProductGroupName = $("select[ng-model='ProductForm.ProductGroup'] option:selected").html();
                        $scope.ProductForm.ProducerName = $("select[ng-model='ProductForm.ProducerId'] option:selected").html();

                        $scope.IsEditingProductDetail = false;
                                                
                        if ($scope.CurrentTab == "Products") {
                            ShowSuccessMessage("Hàng hóa được sửa thành công!");
                        }
                        else if ($scope.CurrentTab == "Combos") {
                            ShowSuccessMessage("Combo được sửa thành công!");
                        }
                    }
                    else {
                        if (isContinue) {
                            $scope.ResetProductForm();
                        }
                        else {
                            $scope.IsEditingProductDetail = false;
                            $scope.IsShowProductDetail = false;
                        }
                        
                        if ($scope.CurrentTab == "Products") {
                            ShowSuccessMessage("Hàng hóa được tạo thành công!");
                        }
                        else if ($scope.CurrentTab == "Combos") {
                            ShowSuccessMessage("Combo được tạo thành công!");
                        }
                    }

                    //Save file
                    var formData = new FormData();
                    formData.append('file', $('[type="file"]:visible')[0].files[0]);
                    formData.append('productId', productId);

                    $.ajax({
                        url: g_saveProductImageUrl,
                        type: 'POST',
                        data: formData,
                        processData: false,  // tell jQuery not to process the data
                        contentType: false,  // tell jQuery not to set contentType
                        success: function (data) {
                            var att = $(".file-preview-image:visible").attr("src")
                            $(".file-preview-image:visible").removeAttr("src").attr("src", att + "&timestamp=" + (new Date().getTime()));
                        }
                    });
                }
            }
        }

        $scope.CopyProduct = function (product) {
            var object = $scope.ProductFormConfig.GetObject(product.ProductId);
            $scope.ProductFormConfig.CopyFields(object, $scope.ProductForm);
            $scope.ProductForm.ProductName = $scope.ProductForm.ProductName + " - Copy";
            $scope.ProductForm.ProductCode = "";
            $scope.ProductForm.Cost = $filter('currency')($scope.ProductForm.Cost, "", 0);
            $scope.ProductForm.Price = $filter('currency')($scope.ProductForm.Price, "", 0);
            $scope.ProductForm.ProductGroupName = product.GroupName;
            $scope.ProductForm.ProducerName = product.ProducerName;
            //$scope.ReloadGrid('ProductAttributes');
            var len = $scope.DataSet.ProductAttributes.Data.length;
            for (var i = 0 ; i < len; i++) {
                $scope.DataSet.ProductAttributes.Data[i].AttributeId += "";
            }
            $scope.ProductForm.OldProductId = $scope.ProductForm.ProductId;
            $scope.ProductForm.ProductId = -1;

            $scope.IsShowProductDetail = true;
            $scope.IsEditingProductDetail = true;
        }


        $scope.ShowProductDetail = function (product) {
            $scope.ResetProductForm();
            var object = $scope.ProductFormConfig.GetObject(product.ProductId);
            $scope.ProductFormConfig.CopyFields(object, $scope.ProductForm);
            $scope.ProductForm.ProductGroupName = product.GroupName;
            $scope.ProductForm.ProducerName = product.ProducerName;
            $scope.ProductForm._CanUpdate = product._CanUpdate;
            $scope.ProductForm._CanDelete = product._CanDelete;
            $scope.IsShowProductDetail = true;
            $scope.IsEditingProductDetail = false;
            $scope.ProductForm.Quantity = product.Quantity;

            if ($scope.CurrentTab == "Products") {
                $scope.ReloadGrid('ProductAttributes');
            }
            else {
                $scope.ReloadGrid('ProductChildren');
                $scope.CalculateCombo();
            }
        }


        $scope.EditProductDetail = function () {
            $scope.IsEditingProductDetail = true;
        }

        $scope.ShowPriceHistory = function (isCost) {
            $scope.ProductForm.IsCost = isCost;
            $scope.SetShownPriceHisModal(true);
            $("#productPriceHistoryModal").modal('show');
            //$scope.ReloadGrid('ProductPriceHistorys');
        }


        //Product Attrubute
        $scope.InitProductAttribute = function () {
            $scope.DataSet.ProductAttributes.Data = [{ AttributeId: '', Value: '', ProductId: $scope.ProductForm.ProductId, Id: '-1' }];
        }

        $scope.AddProductAttribute = function () {
            $scope.DataSet.ProductAttributes.Data.push({ AttributeId: '', Value: '', ProductId: $scope.ProductForm.ProductId, Id: '-1' });
        }

        $scope.DeleteProductAttribute = function (item) {
            if (confirm("Bạn có muốn xóa thuộc tính này?")) {
                var len = $scope.DataSet.ProductAttributes.Data.length;
                for (var i = 0; i < len ; i++) {
                    if (item == $scope.DataSet.ProductAttributes.Data[i]) {
                        $scope.DataSet.ProductAttributes.Data.splice(i, 1);
                        if (item.Id != -1) {
                            $scope.ProductAttributeFormConfig.HardDeleteObject(item.Id);
                        }
                        break;
                    }
                }
            }
        }

        $scope.$watch('IsShowProductDetail', function (newVal, oldVal) {
            if (newVal) {
                setTimeout(function () {
                    $("input[type='file']").fileinput();
                }, 100);
            }
        }, false);


        $scope.SelectProduct = function (product) {
            var hasExist = false;
            for (var i = 0 ; i < $scope.DataSet.ProductChildren.Data.length ; i++) {
                if ($scope.DataSet.ProductChildren.Data[i].ProductId == product.ProductId) {
                    
                    $scope.DataSet.ProductChildren.Data[i].Quantity++;
                    
                    var item = $scope.DataSet.ProductChildren.Data[i];
                    $scope.DataSet.ProductChildren.Data.splice(i, 1);
                    $scope.DataSet.ProductChildren.Data.splice(0, 0, item);

                    hasExist = true;
                    break;
                }
            }
            if (!hasExist) {
                var item = {
                    Id: -1,
                    ProductId: product.ProductId,
                    ProductCode: product.ProductCode,
                    ProductName: product.ProductName,
                    ParentProduct: -1,
                    Price: product.Price,
                    Cost: product.Cost,
                    Quantity: 1
                };
                $scope.DataSet.ProductChildren.Data.splice(0, 0, item);
            }
            $scope.CalculateCombo();
        }

        $scope.DeleteProductFromCombo = function (item) {
            if (confirm("Bạn có muốn xóa sản phẩm này trong combo?")) {
                var len = $scope.DataSet.ProductChildren.Data.length;
                for (var i = 0; i < len ; i++) {
                    if (item == $scope.DataSet.ProductChildren.Data[i]) {
                        $scope.DataSet.ProductChildren.Data.splice(i, 1);
                        if (item.Id != -1) {
                            $scope.ProductComboFormConfig.HardDeleteObject(item.Id);
                        }
                        break;
                    }
                }
                $scope.CalculateCombo();
            }
        }

        $scope.ChangeProductQuantity = function (product, num) {
            num = parseInt(product.Quantity) + num;
            if (num <= 0) {
                ShowErrorMessage("Số lượng tối thiểu là 1");
                num = 1;
            }
            product.Quantity = num;
            $scope.CalculateCombo();
        }

        $scope.CalculateCombo = function () {
            var len = $scope.DataSet.ProductChildren.Data.length;
            var cost = 0;
            var sumPrice = 0;
            for (var i = 0; i < len ; i++) {
                var item = $scope.DataSet.ProductChildren.Data[i];
                sumPrice += item.Price * item.Quantity;
                cost += item.Cost * item.Quantity;
            }
            $scope.ProductForm.Cost = cost;
            $scope.ProductForm.SumPriceInCombo = sumPrice;            
        }

    }]);