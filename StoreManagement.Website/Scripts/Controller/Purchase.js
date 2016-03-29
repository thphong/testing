
function CheckNumOfProduct() {
    var scope = angular.element(document.getElementById("PurchaseController")).scope();
    var len = scope.ListProductsPurchase.length;
    return len > 0;
}

$(document).ready(function () {
    $('input.datepicker').datepicker({ format: 'dd-mm-yyyy'/*, startDate: '23-03-2016'*/ });

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

})


mdlCommon.controller('PurchaseController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('SupplierModalController', { $scope: $scope });

        $scope.AdditionalFilter = {
            PurchaseType: "1",
            StartDate: "",
            EndDate: "",
            Status: "0"
        };

        $scope.RangeDate = 0;
        $scope.SetRangeDate = function (option) {

            var curr = new Date(); // get current date
            var first = curr.getDate() - curr.getDay() + 1; // First day is the day of the month - the day of the week
            var last = first + 6; // last day is the first day + 6
            var y = curr.getFullYear(), m = curr.getMonth();
            var quarter = Math.floor(curr.getMonth() / 3);

            switch (option) {
                case 1: //This week
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(curr.setDate(first)));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(curr.setDate(last)));
                    break;
                case 2: //This month
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(y, m, 1));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(y, m + 1, 0));
                    break;
                case 3: //This quarter
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(y, quarter * 3, 1));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(y, quarter * 3 + 3, 0));
                    break;
                case 4: //last week
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(curr.setDate(first - 7)));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(curr.setDate(last - 7)));
                    break;
                case 5: //Last month
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(y, m - 1, 1));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(y, m, 0));
                    break;
                case 6: //Last quarter
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(y, (quarter - 1) * 3, 1));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(y, quarter * 3, 0));
                    break;
            }
            $scope.RangeDate = option;
            $scope.ReloadGrid('Purchases');
        }

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

        $scope.DeletePurchase = function (purchase) {
            if (confirm("Bạn có muốn xóa đơn hàng " + purchase.PurchaseCode + "?")) {
                if ($scope.PurchaseFormConfig.DeleteObject(purchase.PurchaseCode, "PurchaseCode")) {
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
                    PurchaseId: '-1',
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
            if (confirm("Bạn có muốn xóa sản phẩm '" + product.ProductCode + " - " + product.ProductName + "' trong hóa đơn?")) {

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
                        $scope.ReloadGrid('Purchases');
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
            $scope.ReloadGrid('ProductsPurchase');
            $scope.ListProductsPurchase = $scope.DataSet.ProductsPurchase.Data;

            FValidation.ClearAllError();

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