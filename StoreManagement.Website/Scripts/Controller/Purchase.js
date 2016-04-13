
function CheckNumOfProduct() {
    var scope = angular.element(document.getElementById("PurchaseController")).scope();
    var len = scope.ListProductsPurchase.length;
    return len > 0;
}

$(document).ready(function () {
    $('input.datepicker').datepicker({ format: 'dd-mm-yyyy'/*, startDate: '23-03-2016'*/ });
})


mdlCommon.controller('PurchaseController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('SupplierModalController', { $scope: $scope });

        $scope.AdditionalFilter = {
            PurchaseType: "1",
            Status: "0"
        };
        
        $scope.PurchaseFormConfig = new ObjectDataConfig("T_Trans_Purchase");
        $scope.ProductPurchaseFormConfig = new ObjectDataConfig("T_Trans_Purchase_Product");

        $scope.IsShowPurchaseDetail = false;

        $scope.PurchaseForm = {
            PurchaseId: "-1",
            PurchaseCode: "",
            StoreId: "",
            SupplierId: "",
            SupplierName: "",
            PurchaseDate: "",
            Purchaser: $scope.CurrentUser,
            PurchaserName: "",
            Notes: "",
            StatusId: 1,
            PaymentType: '1',
            Price: '0', //sum before tax
            SumMoney: '0',
            SumTax: '0',
            Debt: '0',
            Paid: 0,
            IsActive: '1'
        };

        $scope.ResetPurchaseForm = function () {
            $scope.PurchaseForm.PurchaseId = "-1";
            $scope.PurchaseForm.PurchaseCode = "";
            $scope.PurchaseForm.StoreId = "";
            $scope.PurchaseForm.SupplierId = "";
            $scope.PurchaseForm.SupplierName = "";
            $scope.PurchaseForm.PurchaseDate = "";
            $scope.PurchaseForm.Purchaser = $scope.CurrentUser;
            $scope.PurchaseForm.PurchaserName = "";
            $scope.PurchaseForm.Notes = "";
            $scope.PurchaseForm.StatusId = 1;
            $scope.PurchaseForm.PaymentType = '1';
            $scope.PurchaseForm.SumMoney = '0';
            $scope.PurchaseForm.SumTax = '0';
            $scope.PurchaseForm.Price = '0';
            $scope.PurchaseForm.Debt = '0';
            $scope.PurchaseForm.Paid = 0;
            $scope.PurchaseForm.IsActive = '1';
        }

        $scope.ListProductsPurchase = [];

        $scope.AddPurchase = function () {
            $scope.IsShowPurchaseDetail = true;
            FValidation.ClearAllError();
            $scope.ResetPurchaseForm();
            $scope.ListProductsPurchase = [];
        }

        $scope.ClosePurchaseDetail = function () {
            $scope.IsShowPurchaseDetail = false;
        }

        $scope.InitListAutoCompleteProducts = function () {
            $("#txtSearchProduct").autocomplete({
                minLength: 0,
                source: function (request, response) {
                    var configList = new GridViewConfig("");
                    configList.GridDataAction = "get10";
                    configList.GridDataObject = "T_Trans_Products";
                    configList.GridDefinedColums = "ProductId;ProductCode;ProductName;Price;Cost;VAT";
                    configList.GridFilterCondition = "IsSelling = 1 and IsActive = 1 and (ProductCode like N''%" + request.term + "%'' or ProductName like N''%" + request.term + "%'')";
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
                        var scope = angular.element(document.getElementById("PurchaseController")).scope();
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

        }

        $scope.DeletePurchase = function (purchase) {
            if (confirm("Bạn có muốn xóa đơn hàng " + purchase.PurchaseCode + "?")) {
                if ($scope.PurchaseFormConfig.DeleteObject(purchase.PurchaseId)) {
                    $scope.ReloadGrid('Purchases');
                    ShowSuccessMessage("Đơn hàng được xóa thành công!");
                }
            }
        }

        $scope.SelectProduct = function (product) {
            var hasExist = false;
            for (var i = 0 ; i < $scope.ListProductsPurchase.length ; i++) {
                if ($scope.ListProductsPurchase[i].ProductId == product.ProductId) {
                    $scope.ListProductsPurchase[i].Quantity++;
                    $scope.ListProductsPurchase[i].RealCost = $scope.ListProductsPurchase[i].Quantity * $scope.ListProductsPurchase[i].Cost;
                    hasExist = true;
                    break;
                }
            }
            if (!hasExist) {
                var item = {
                    Id: "-1",
                    PurchaseId: $scope.PurchaseForm.PurchaseId,
                    RowNum: $scope.ListProductsPurchase.length + 1,
                    ProductId: product.ProductId,
                    ProductCode: product.ProductCode,
                    ProductName: product.ProductName,
                    Price: product.Price,
                    Cost: product.Cost,
                    VAT: product.VAT,
                    Quantity: 1,
                    RealCost: product.Cost
                }
                $scope.ListProductsPurchase.push(item);
            }
            $scope.Summarize();
        }

        $scope.ChangeProductQuantity = function (product, num) {
            num = parseInt(product.Quantity) + num;
            if (num <= 0) {
                ShowErrorMessage("Số lượng tối thiểu là 1");
                num = 1;
            }
            product.Quantity = num;
            //Recalcualte Real Price

            product.RealCost = product.Quantity * product.Cost;

            $scope.Summarize();
        }


        $scope.ChangeCost = function (product) {
            product.Cost = parseInt(product.Cost);
            product.RealCost = product.Quantity * product.Cost;
            $scope.Summarize();
        }

        $scope.DeleteProductPurchase = function (product) {
            if (confirm("Bạn có muốn xóa sản phẩm '" + product.ProductCode + " - " + product.ProductName + "' trong phiếu nhập?")) {

                if (product.Id != "-1") {
                    $scope.ProductPurchaseFormConfig.HardDeleteObject(product.Id);
                }

                for (var i = 0 ; i < $scope.ListProductsPurchase.length ; i++) {
                    if ($scope.ListProductsPurchase[i].ProductId == product.ProductId) {
                        $scope.ListProductsPurchase.splice(i, 1);
                        break;
                    }
                }

                ShowSuccessMessage("Sản phẩm được xóa khỏi đơn hàng thành công!");

                $scope.Summarize();
            }
        }

        $scope.Summarize = function () {
            var sum = 0, tax = 0;
            for (var i = 0 ; i < $scope.ListProductsPurchase.length ; i++) {
                var item = $scope.ListProductsPurchase[i];
                sum += parseInt(item.RealCost);
                tax += parseInt(item.RealCost * item.VAT / 100);
            }
            $scope.PurchaseForm.Price = sum;
            $scope.PurchaseForm.SumTax = tax;
            $scope.PurchaseForm.SumMoney = sum + tax;
            //$scope.PurchaseForm.Paid = sum + tax;
            $scope.PurchaseForm.Debt = $scope.PurchaseForm.SumMoney - $scope.PurchaseForm.Paid;
        }

        $scope.ChangePaid = function () {
            $scope.PurchaseForm.Paid = parseInt($scope.PurchaseForm.Paid);
            $scope.PurchaseForm.Debt = $scope.PurchaseForm.SumMoney - $scope.PurchaseForm.Paid;
            if ($scope.PurchaseForm.Debt < 0) {
                $scope.PurchaseForm.Debt = '0';
            }
        }

        $scope.SavePurchaseForm = function (status) {
            if (FValidation.CheckControls("check-purchase")) {
                $scope.PurchaseForm.StatusId = status;
                $scope.PurchaseForm.StoreId = $scope.CurrentStore;
                $scope.PurchaseFormConfig.SetObject($scope.PurchaseForm);
                var purchaseId = $scope.PurchaseFormConfig.SaveObject();
                if (purchaseId > 0) {

                    if ($scope.PurchaseForm.PurchaseId == '-1') {
                        var len = $scope.ListProductsPurchase.length;
                        for (var i = 0 ; i < len; i++) {
                            $scope.ListProductsPurchase[i].PurchaseId = purchaseId;
                        }
                    }

                    $scope.ProductPurchaseFormConfig.SetListObject($scope.ListProductsPurchase);
                    var result = $scope.ProductPurchaseFormConfig.SaveListObject();

                    if (result) {
                        ShowSuccessMessage("Đơn hàng được lưu thành công!");
                        //$scope.ReloadGrid('Purchases');
                        $scope.IsShowPurchaseDetail = false;
                    }
                    else if ($scope.PurchaseForm.PurchaseId == '-1') {
                        $scope.PurchaseFormConfig.HardDeleteObject(purchaseId);
                    }
                }
            }
        }


        $scope.ShowPurchaseDetail = function (purchase) {
            //Load purchase form
            $scope.PurchaseFormConfig.SetObject($scope.PurchaseForm);
            var object = $scope.PurchaseFormConfig.GetObject(purchase.PurchaseId);
            $scope.PurchaseFormConfig.ConvertFieldsToString(object, $scope.PurchaseForm);
            $scope.PurchaseForm.SupplierName = purchase.SupplierName;
            $scope.PurchaseForm.PurchaserName = purchase.PurchaserName;
            $scope.IsShowPurchaseDetail = true;

            //Load Product purchase
            //$scope.ReloadGrid('ProductsPurchase');
            //FValidation.ClearAllError();
        }

        $scope.InitListProducts = function () {
            $scope.ListProductsPurchase = $scope.DataSet.ProductsPurchase.Data;

            var len = $scope.ListProductsPurchase.length;
            for (var i = 0 ; i < len; i++) {
                var item = $scope.ListProductsPurchase[i];

                item.RealCost = item.Quantity * item.Cost;

                item.RowNum = i + 1;
            }

            $scope.Summarize();
        }

        $scope.ExposeFunctionAfterSavingSupplier = function () {
            $scope.PurchaseForm.SupplierId = $scope.SupplierForm.SupplierId;
            $scope.PurchaseForm.SupplierName = $scope.SupplierForm.SupplierName;
        }

    }]);