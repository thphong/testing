function CheckNumOfProduct() {
    var scope = angular.element(document.getElementById("InventoryController")).scope();
    var len = scope.ListProductsInventory.length;
    return len > 0;
}

function CheckNumOfProductTran() {
    var scope = angular.element(document.getElementById("InventoryController")).scope();
    var len = scope.ListProductsInventTran.length;
    return len > 0;
}


$(document).ready(function () {
    $('input.datepicker').datepicker({ format: 'dd-mm-yyyy'/*, startDate: '23-03-2016'*/ });

    $(".txtSearchProduct").each(function () {
        $(this).autocomplete({
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
                    $(".txtSearchProduct").val("").change();
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

            InventoryStatus: "0",

            InventTranStatus: "0"
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
        $scope.InventTranFormConfig = new ObjectDataConfig("T_Trans_InventTran");
        $scope.ProductInventTranFormConfig = new ObjectDataConfig("T_Trans_InventTran_Product");
        $scope.IsShowInventoryDetail = false;
        $scope.IsShowInventTranDetail = false;
        $scope.ListProductsInventory = [];
        $scope.ListProductsInventTran = [];

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

        $scope.InventTranForm = {
            InventTranId: "-1",
            InventTranCode: "",
            FromStoreId: $scope.CurrentStore,
            ToStoreId: "",
            FromStoreCode: "",
            ToStoreCode: "",
            CreatedDate: "",
            CreatorName: "",
            TransferedDate: "",
            TransferName: "",
            Notes: "",
            StatusId: 1,
            IsActive: 1,
            NumProducts: 0
        }

        $scope.ResetInventTranForm = function () {
            $scope.InventTranForm.InventTranId = "-1";
            $scope.InventTranForm.InventTranCode = "";
            $scope.InventTranForm.FromStoreId = $scope.CurrentStore;
            $scope.InventTranForm.ToStoreId = "";
            $scope.InventTranForm.CreatedDate = "";
            $scope.InventTranForm.CreatorName = "";
            $scope.InventTranForm.TransferedDate = "";
            $scope.InventTranForm.TransferName = "";
            $scope.InventTranForm.Notes = "";
            $scope.InventTranForm.StatusId = 1;
            $scope.InventTranForm.IsActive = 1;
            $scope.InventTranForm.NumProducts = 0;
        }

        $scope.AddInventory = function () {
            $scope.IsShowInventoryDetail = true;
            FValidation.ClearAllError();
            $scope.ResetInventoryForm();
            $scope.ListProductsInventory = [];
        }

        $scope.AddInventTran = function () {
            $scope.IsShowInventTranDetail = true;
            FValidation.ClearAllError();
            $scope.ResetInventTranForm();
            $scope.ListProductsInventTran = [];
        }

        $scope.CloseInventoryDetail = function () {
            $scope.IsShowInventoryDetail = false;
        }

        $scope.CloseInventTranDetail = function () {
            $scope.IsShowInventTranDetail = false;
        }

        $scope.DeleteInventory = function (inventory) {
            if (confirm("Bạn có muốn xóa phiếu kiểm kê " + inventory.InventoryCode + "?")) {
                if ($scope.InventoryFormConfig.DeleteObject(inventory.InventoryId)) {
                    $scope.ReloadGrid('InventoryCheck');
                    ShowSuccessMessage("Phiếu kiểm kê được xóa thành công!");
                }
            }
        }

        $scope.DeleteInventTran = function (tranfer) {
            if (confirm("Bạn có muốn xóa phiếu chuyển kho " + tranfer.InventTranCode + "?")) {
                if ($scope.InventTranFormConfig.DeleteObject(tranfer.InventTranId)) {
                    $scope.ReloadGrid('InventTrans');
                    ShowSuccessMessage("Phiếu chuyển kho được xóa thành công!");
                }
            }
        }

        $scope.SelectProduct = function (product) {

            if ($scope.CurrentTab == "InventoryCheck") {
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
                        Notes: ""
                    }
                    $scope.ListProductsInventory.push(item);
                }
                $scope.SummarizeInventory();
            }
            else {
                if (product.Quantity <= 0) {
                    ShowErrorMessage("Chỉ chuyển được hàng hóa còn tồn trong cửa hàng");
                    return;
                }
                var hasExist = false;
                for (var i = 0 ; i < $scope.ListProductsInventTran.length ; i++) {
                    if ($scope.ListProductsInventTran[i].ProductId == product.ProductId) {
                        ShowErrorMessage("Bạn đã chọn hàng hóa này trong phiếu chuyển kho");
                        hasExist = true;
                        break;
                    }
                }
                if (!hasExist) {
                    var item = {
                        Id: "-1",
                        InventTranId: $scope.InventTranForm.InventTranId,
                        RowNum: $scope.ListProductsInventTran.length + 1,
                        ProductId: product.ProductId,
                        ProductCode: product.ProductCode,
                        ProductName: product.ProductName,
                        Quantity: product.Quantity,
                        TranQuantity: "",
                        Notes: ""
                    }
                    $scope.ListProductsInventTran.push(item);
                }
                $scope.SummarizeInventTran();
            }
        }

        $scope.ChangeQuantity = function (item) {
            item.RealQuantity = parseInt(item.RealQuantity);
            item.Diff = item.RealQuantity - item.Quantity;

            $scope.SummarizeInventory();
        }

        $scope.ChangeTranQuantity = function (item) {
            if (item.TranQuantity != "") {
                item.TranQuantity = parseInt(item.TranQuantity);
                if (item.TranQuantity > item.Quantity) {
                    ShowErrorMessage("Số lượng chuyển không được vượt quá lượng tồn");
                    item.TranQuantity = item.Quantity;
                }
                $scope.SummarizeInventTran();
            }
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

                $scope.SummarizeInventory();
            }
        }

        $scope.DeleteProductInventTran = function (product) {
            if (confirm("Bạn có muốn xóa sản phẩm '" + product.ProductCode + " - " + product.ProductName + "' trong phiếu chuyển kho?")) {

                if (product.Id != "-1") {
                    $scope.ProductInventTranFormConfig.HardDeleteObject(product.Id);
                }

                for (var i = 0 ; i < $scope.ListProductsInventTran.length ; i++) {
                    if ($scope.ListProductsInventTran[i].ProductId == product.ProductId) {
                        $scope.ListProductsInventTran.splice(i, 1);
                        break;
                    }
                }

                ShowSuccessMessage("Sản phẩm được xóa khỏi phiếu thành công!");

                $scope.SummarizeInventTran();
            }
        }

        $scope.SummarizeInventory = function () {
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

        $scope.SummarizeInventTran = function () {
            $scope.InventTranForm.NumProducts = $scope.ListProductsInventTran.length;
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

        $scope.SaveInventTranForm = function (status) {
            if (FValidation.CheckControls("check-inventory-tran")) {
                $scope.InventTranForm.StatusId = status;
                $scope.InventTranFormConfig.SetObject($scope.InventTranForm);
                var inventTranId = $scope.InventTranFormConfig.SaveObject();
                if (inventTranId > 0) {
                    if ($scope.InventTranForm.InventTranId == '-1') {
                        var len = $scope.ListProductsInventTran.length;
                        for (var i = 0 ; i < len; i++) {
                            $scope.ListProductsInventTran[i].InventTranId = inventTranId;
                        }
                    }

                    $scope.ProductInventTranFormConfig.SetListObject($scope.ListProductsInventTran);
                    var result = $scope.ProductInventTranFormConfig.SaveListObject();

                    if (result) {
                        ShowSuccessMessage("Phiếu chuyển kho được lưu thành công!");
                        $scope.ReloadGrid('InventTrans');
                        $scope.IsShowInventTranDetail = false;
                    }
                    else if ($scope.InventTranForm.InventTranId == '-1') {
                        $scope.InventTranFormConfig.HardDeleteObject(inventTranId);
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

            $scope.SummarizeInventory();
        }


        $scope.ShowInventTranDetail = function (tran) {
            //Load Inventory form
            $scope.InventTranFormConfig.SetObject($scope.InventTranForm);
            var object = $scope.InventTranFormConfig.GetObject(tran.InventTranId);
            $scope.InventTranFormConfig.ConvertFieldsToString(object, $scope.InventTranForm);
            $scope.InventTranForm.TransferName = tran.TransferName;
            $scope.InventTranForm.CreatorName = tran.CreatorName;
            $scope.InventTranForm.FromStoreCode = tran.FromStoreCode;
            $scope.InventTranForm.ToStoreCode = tran.ToStoreCode;
            $scope.IsShowInventTranDetail = true;

            //Load Product InventTran
            $scope.ReloadGrid('ProductsInventTran');
            $scope.ListProductsInventTran = $scope.DataSet.ProductsInventTran.Data;

            FValidation.ClearAllError();

            var len = $scope.ListProductsInventTran.length;
            for (var i = 0 ; i < len; i++) {
                var item = $scope.ListProductsInventTran[i];

                item.Diff = item.RealQuantity - item.Quantity;

                item.RowNum = i + 1;
            }

            $scope.SummarizeInventTran();
        }
    }]);