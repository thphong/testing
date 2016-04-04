function CheckNumOfProduct() {
    var scope = angular.element(document.getElementById("InventoryController")).scope();
    var len = scope.ListProductsInventory.length;
    return len > 0;
}


$(document).ready(function () {
    $('input.datepicker').datepicker({ format: 'dd-mm-yyyy'/*, startDate: '23-03-2016'*/ });

    $("#txtSearchProduct").autocomplete({
        minLength: 0,
        source: function (request, response) {
            var configList = new GridViewConfig("");
            configList.GridDataAction = "get10";
            configList.GridDataObject = "T_Trans_Product_Store";
            configList.GridDefinedColums = "ProductId;ProductId.ProductCode;ProductId.ProductName;Quantity;#ProductId.IsSelling;#ProductId.IsActive";
            configList.GridFilterCondition = "T_Trans_Product_Store.StoreId = " + g_currentStoreId + " and ProductId.IsSelling = 1 and ProductId.IsActive = 1 and (ProductId.ProductCode like N''%" + request.term + "%'' or ProductId.ProductName like N''%" + request.term + "%'')";
            configList.GridSortCondition = "ProductCode ASC";

            var listData = configList.GetListData();
            if (listData.length > 0) {
                response(listData);
            }
            else {
                response(["Không tìm thấy kết quả"]);
            }
        },
        select: function (event, ui) {
            if (ui.item.ProductCode) {
                var scope = angular.element(document.getElementById("InventoryController")).scope();
                scope.$apply(function () {
                    scope.SelectProduct(ui.item);
                });
                $("#txtSearchProduct").val("").change();
            }
            return false;
        }
    })
    .autocomplete("instance")._renderItem = function (ul, item) {
        var content;
        if (item.ProductCode) {
            content = "<a> <b>" + item.ProductCode + " </b><br> " + item.ProductName + "</a>";
        }
        else {
            content = "<a>" + item.label + "</a>";
        }
        return $("<li>")
                .append(content)
                .appendTo(ul);
    };

});


mdlCommon.controller('InventoryController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('ProductQuanHistoryController', { $scope: $scope });

        $scope.AdditionalFilter = {
            InventoryProductGroup: "0",
            InventoryProductType: "0",

            InventoryInOutProductGroup: "0",
            InventoryInOutStartDate: "",
            InventoryInOutEndDate: "",

            InventoryStatus: "0"
        };

        $scope.CurrentTab = "InventoryProduct";
        $scope.CurrentDate = new Date();
        

        $scope.SetCurrentTab = function (tab) {
            if (tab != $scope.CurrentTab) {
                $scope.CurrentTab = tab;
                $scope.ReloadGrid(tab);
            }
        }

        $scope.InventoryFormConfig = new ObjectDataConfig("T_Trans_Inventory");
        $scope.ProductInventoryFormConfig = new ObjectDataConfig("T_Trans_Inventory_Product");
        $scope.IsShowInventoryDetail = false;
        $scope.ListProductsInventory = [];

        $scope.InventoryForm = {
            InventoryId: "-1",
            InventoryCode: "",
            BalancedDate: "",
            BalancerName: "",
            CreatedDate: "",
            CreatorName: "",
            StoreId: $scope.CurrentStore,
            StatusId: 1,
            IsActive: 1,
            NumProducts: 0,
            NumDiffs: 0,
            NumMore: 0,
            NumLess: 0
        }

        $scope.ResetInventoryForm = function () {
            $scope.InventoryForm.InventoryId = "-1";
            $scope.InventoryForm.InventoryCode = "";
            $scope.InventoryForm.BalancedDate = "";
            $scope.InventoryForm.BalancerName = "";
            $scope.InventoryForm.CreatedDate = "";
            $scope.InventoryForm.CreatorName = "";
            $scope.InventoryForm.StoreId = $scope.CurrentStore;
            $scope.InventoryForm.StatusId = 1;
            $scope.InventoryForm.IsActive = 1;
            $scope.InventoryForm.NumProducts = 0;
            $scope.InventoryForm.NumDiffs = 0;
            $scope.InventoryForm.NumMore = 0;
            $scope.InventoryForm.NumLess = 0;
        }

        $scope.AddInventory = function () {
            $scope.IsShowInventoryDetail = true;
            FValidation.ClearAllError();
            $scope.ResetInventoryForm();
            $scope.ListProductsInventory = [];
        }

        $scope.CloseInventoryDetail = function () {
            $scope.IsShowInventoryDetail = false;
        }

        $scope.DeleteInventory = function (inventory) {
            if (confirm("Bạn có muốn xóa phiếu kiểm kê " + inventory.InventoryCode + "?")) {
                if ($scope.InventoryFormConfig.DeleteObject(inventory.InventoryId)) {
                    $scope.ReloadGrid('InventoryCheck');
                    ShowSuccessMessage("Phiếu kiểm kê được xóa thành công!");
                }
            }
        }

        $scope.SelectProduct = function (product) {
            var hasExist = false;
            for (var i = 0 ; i < $scope.ListProductsInventory.length ; i++) {
                if ($scope.ListProductsInventory[i].ProductId == product.ProductId) {
                    ShowErrorMessage("Bạn đã chọn hàng hóa này trong phiếu kiểm kê");
                    hasExist = true;
                    break;
                }
            }
            if (!hasExist) {
                var item = {
                    Id: "-1",
                    InventoryId: $scope.InventoryForm.InventoryId,
                    RowNum: $scope.ListProductsInventory.length + 1,
                    ProductId: product.ProductId,
                    ProductCode: product.ProductCode,
                    ProductName: product.ProductName,
                    Quantity: product.Quantity,
                    RealQuantity: "",
                    Diff: "",
                    Notes : ""
                }
                $scope.ListProductsInventory.push(item);
            }
            $scope.Summarize();
        }

        $scope.ChangeQuantity = function (item) {
            item.RealQuantity = parseInt(item.RealQuantity);
            item.Diff = item.RealQuantity - item.Quantity;

            $scope.Summarize();
        }


        $scope.DeleteProductInventory = function (product) {
            if (confirm("Bạn có muốn xóa sản phẩm '" + product.ProductCode + " - " + product.ProductName + "' trong phiếu kiểm kê?")) {

                if (product.Id != "-1") {
                    $scope.ProductInventoryFormConfig.HardDeleteObject(product.Id);
                }

                for (var i = 0 ; i < $scope.ListProductsInventory.length ; i++) {
                    if ($scope.ListProductsInventory[i].ProductId == product.ProductId) {
                        $scope.ListProductsInventory.splice(i, 1);
                        break;
                    }
                }

                ShowSuccessMessage("Sản phẩm được xóa khỏi phiếu thành công!");

                $scope.Summarize();
            }
        }

        $scope.Summarize = function () {
            $scope.InventoryForm.NumProducts = $scope.ListProductsInventory.length;
            $scope.InventoryForm.NumDiffs = 0;
            $scope.InventoryForm.NumMore = 0;
            $scope.InventoryForm.NumLess = 0;

            for (var i = 0 ; i < $scope.ListProductsInventory.length ; i++) {
                var item = $scope.ListProductsInventory[i];
                $scope.InventoryForm.NumDiffs += (item.Quantity != item.RealQuantity);
                $scope.InventoryForm.NumMore += (item.Quantity < item.RealQuantity);
                $scope.InventoryForm.NumLess += (item.Quantity > item.RealQuantity)
            }
        }

        $scope.SaveInventoryForm = function (status) {
            if (FValidation.CheckControls("check-inventory")) {
                $scope.InventoryForm.StatusId = status;
                $scope.InventoryFormConfig.SetObject($scope.InventoryForm);
                var inventoryId = $scope.InventoryFormConfig.SaveObject();
                if (inventoryId > 0) {
                    if ($scope.InventoryForm.InventoryId == '-1') {
                        var len = $scope.ListProductsInventory.length;
                        for (var i = 0 ; i < len; i++) {
                            $scope.ListProductsInventory[i].InventoryId = inventoryId;
                        }
                    }

                    $scope.ProductInventoryFormConfig.SetListObject($scope.ListProductsInventory);
                    var result = $scope.ProductInventoryFormConfig.SaveListObject();

                    if (result) {
                        ShowSuccessMessage("Phiếu kiểm kê được lưu thành công!");
                        $scope.ReloadGrid('InventoryCheck');
                        $scope.IsShowInventoryDetail = false;
                    }
                    else if ($scope.InventoryForm.InventoryId == '-1') {
                        $scope.InventoryFormConfig.HardDeleteObject(inventoryId);
                    }
                }
            }
        }


        $scope.ShowInventoryDetail = function (inventory) {
            //Load Inventory form
            $scope.InventoryFormConfig.SetObject($scope.InventoryForm);
            var object = $scope.InventoryFormConfig.GetObject(inventory.InventoryId);
            $scope.InventoryFormConfig.ConvertFieldsToString(object, $scope.InventoryForm);
            $scope.InventoryForm.BalancerName = inventory.BalancerName;
            $scope.InventoryForm.CreatorName = inventory.CreatorName;
            $scope.IsShowInventoryDetail = true;

            //Load Product Inventory
            $scope.ReloadGrid('ProductsInventory');
            $scope.ListProductsInventory = $scope.DataSet.ProductsInventory.Data;

            FValidation.ClearAllError();

            var len = $scope.ListProductsInventory.length;
            for (var i = 0 ; i < len; i++) {
                var item = $scope.ListProductsInventory[i];

                item.Diff = item.RealQuantity - item.Quantity;

                item.RowNum = i + 1;
            }

            $scope.Summarize();
        }


    }]);