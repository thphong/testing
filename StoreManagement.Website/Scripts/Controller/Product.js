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

$(document).ready(function () {
    $('#productPriceHistoryModal').on('hide.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownPriceHisModal(false);
        });
    });
});

mdlCommon.controller('ProductController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('ProductGroupController', { $scope: $scope });
        $controller('ProducerController', { $scope: $scope });
        $controller('AttributeController', { $scope: $scope });
        $controller('ProductQuanHistoryController', { $scope: $scope });

        $scope.AdditionalFilter = {
            ProductStatus: "1",
            ProductGroup: "0",
            Producer: "0"
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
            AllowNegative: 1,
            Cost: 0,
            Price: 0,
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
            _CanUpdate: true,
            _CanDelete: true
        };

        $scope.ResetProductForm = function () {
            $scope.ProductForm.OldProductId = -1;
            $scope.ProductForm.ProductId = -1;
            $scope.ProductForm.ProductCode = "";
            $scope.ProductForm.ProductName = "";
            $scope.ProductForm.TrackInventory = 1;
            $scope.ProductForm.AllowNegative = 1;
            $scope.ProductForm.Cost = 0;
            $scope.ProductForm.Price = 0;
            $scope.ProductForm.ProductGroup = "";
            $scope.ProductForm.ProducerId = "";
            $scope.ProductForm.VAT = "0";
            $scope.ProductForm.IsSelling = 1;
            $scope.ProductForm.IsActive = 1;
            $scope.ProductForm.AllowMin = 0;
            $scope.ProductForm.AllowMax = 100;
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
        };

        $scope.ProductFormConfig = new ObjectDataConfig("T_Trans_Products", $scope);
        $scope.ProductAttributeFormConfig = new ObjectDataConfig("T_Trans_Product_Attribute", $scope);

        $scope.ProductFormConfig.CheckCanCreateObject();

        $scope.IsShownPriceHisModal = false;
        $scope.SetShownPriceHisModal = function (isShown) {
            $scope.IsShownPriceHisModal = isShown;
        }

        $scope.DeleteProduct = function (product) {
            if (confirm("Bạn có muốn xóa hàng hóa " + product.ProductCode + " - " + product.ProductName + "?")) {
                if ($scope.ProductFormConfig.DeleteObject(product.ProductId)) {
                    $scope.ReloadGrid('Products');
                    product.IsActive = 0;
                    ShowSuccessMessage("Hàng hóa được xóa thành công!");
                }
            }
        }

        $scope.StopSellingProduct = function (product) {
            if (confirm("Bạn có muốn ngừng kinh doanh hàng hóa " + product.ProductCode + " - " + product.ProductName + "?")) {
                $scope.ProductFormConfig.SetObject({ "ProductId": product.ProductId, "IsSelling": "0" });
                if ($scope.ProductFormConfig.SaveObject()) {
                    $scope.ReloadGrid('Products');
                    product.IsSelling = 0;
                    ShowSuccessMessage("Nhưng kinh doanh hàng " + product.ProductCode + " - " + product.ProductName + " thành công!");
                }
            }
        }

        $scope.EnableSellingProduct = function (product) {
            if (confirm("Bạn có muốn cho phép kinh doanh hàng hóa " + product.ProductCode + " - " + product.ProductName + "?")) {
                $scope.ProductFormConfig.SetObject({ "ProductId": product.ProductId, "IsSelling": "1" });
                if ($scope.ProductFormConfig.SaveObject()) {
                    $scope.ReloadGrid('Products');
                    product.IsSelling = 1;
                    ShowSuccessMessage("Cho phép kinh doanh hàng " + product.ProductCode + " - " + product.ProductName + " thành công!");
                }
            }
        }

        $scope.AddProduct = function () {
            $scope.IsShowProductDetail = true;
            $scope.IsEditingProductDetail = true;
            FValidation.ClearAllError();
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


                var productId = $scope.ProductFormConfig.SaveObject();
                if (productId > 0) {
                    if ($scope.ProductForm.ProductId != -1) {

                        $scope.ProductForm.ProductGroupName = $("select[ng-model='ProductForm.ProductGroup'] option:selected").html();
                        $scope.ProductForm.ProducerName = $("select[ng-model='ProductForm.ProducerId'] option:selected").html();

                        $scope.IsEditingProductDetail = false;
                        //$scope.ReloadGrid('Products');

                        ShowSuccessMessage("Hàng hóa được sửa thành công!");
                    }
                    else {
                        //save product attribute
                        var len = $scope.DataSet.ProductAttributes.Data.length;
                        for (var i = 0 ; i < len; i++) {
                            $scope.DataSet.ProductAttributes.Data[i].ProductId = productId;
                        }
                        $scope.ProductAttributeFormConfig.SetListObject($scope.DataSet.ProductAttributes.Data);
                        $scope.ProductAttributeFormConfig.SaveListObject();

                        if (isContinue) {
                            $scope.ResetProductForm();
                        }
                        else {
                            $scope.IsEditingProductDetail = false;
                            $scope.IsShowProductDetail = false;
                        }
                        ShowSuccessMessage("Hàng hóa được tạo thành công!");
                        //$scope.ReloadGrid('Products');
                    }

                    //Save file
                    var formData = new FormData();
                    formData.append('file', $('#fileImage')[0].files[0]);
                    formData.append('productId', productId);

                    $.ajax({
                        url: g_saveProductImageUrl,
                        type: 'POST',
                        data: formData,
                        processData: false,  // tell jQuery not to process the data
                        contentType: false,  // tell jQuery not to set contentType
                        success: function (data) {
                            var att = $("#imgProduct").attr("src")
                            $("#imgProduct").removeAttr("src").attr("src", att + "&timestamp=" + (new Date().getTime()));
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
            //$scope.ReloadGrid('ProductAttributes');
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
            $scope.DataSet.ProductAttributes.Data = [{ AttributeId: '', Value: '' }];
        }

        $scope.AddProductAttribute = function () {
            $scope.DataSet.ProductAttributes.Data.push({ AttributeId: "", Value: "" });
        }

        $scope.DeleteProductAttribute = function (item) {
            if (confirm("Bạn có muốn xóa thuộc tính này?")) {
                var len = $scope.DataSet.ProductAttributes.Data.length;
                for (var i = 0; i < len ; i++) {
                    if (item == $scope.DataSet.ProductAttributes.Data[i]) {
                        $scope.DataSet.ProductAttributes.Data.splice(i, 1);
                        break;
                    }
                }
            }
        }

        $scope.$watch('IsShowProductDetail', function (newVal, oldVal) {
            if (newVal) {
                setTimeout(function () {
                    $("#fileImage").fileinput();
                }, 100);
            }
        }, false);

    }]);