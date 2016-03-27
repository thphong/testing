
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
            configList.GridDefinedColums = "ProductId;ProductCode;ProductName;Quantity;Price;AllowNegative";
            configList.GridFilterCondition = "IsSelling = 1 and IsActive = 1 and (Quantity > 0 or AllowNegative = 1) and (ProductCode like N''%" + request.term + "%'' or ProductName like N''%" + request.term + "%'')";
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
            content = "<a> <b>" + item.ProductName + " </b><br> Mã : " + item.ProductCode + "<br> Giá : " + item.Price + " | Tồn : " + item.Quantity + " </a>";
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
        $scope.ProductFormConfig = new ObjectDataConfig("T_Trans_Products");

        $scope.IsShowPurchaseDetail = false;

        $scope.PurchaseForm = {
            PurchaseId: "-1",
            PurchaseCode: "",
            StoreId: "",
            Customer: "",
            CustomerName: "",
            PurchaseDate: "",
            Cashier: $scope.CurrentUser,
            PurchaserName: "",
            Notes: "",
            StatusId: 1,
            PaymentType: '1',
            Price: '0', //sum before discount
            SumMoney: '0',
            Discount: '0',
            DiscountAmmount: '0',
            TotalDiscount: '0',
            Debt: '0',
            Paid: '0',
            IsDiscountPercent: '1',
            IsActive: '1'
        };

        $scope.ResetPurchaseForm = function () {
            $scope.PurchaseForm.PurchaseId = "-1";
            $scope.PurchaseForm.PurchaseCode = "";
            $scope.PurchaseForm.StoreId = "";
            $scope.PurchaseForm.Customer = "";
            $scope.PurchaseForm.CustomerName = "";
            $scope.PurchaseForm.PurchaseDate = "";
            $scope.PurchaseForm.Cashier = $scope.CurrentUser;
            $scope.PurchaseForm.PurchaserName = "";
            $scope.PurchaseForm.Notes = "";
            $scope.PurchaseForm.StatusId = 1;
            $scope.PurchaseForm.PaymentType = '1';
            $scope.PurchaseForm.SumMoney = '0';
            $scope.PurchaseForm.Price = '0';
            $scope.PurchaseForm.Discount = '0';
            $scope.PurchaseForm.DiscountAmmount = '0';
            $scope.PurchaseForm.TotalDiscount = '0';
            $scope.PurchaseForm.Debt = '0';
            $scope.PurchaseForm.Paid = '0';
            $scope.PurchaseForm.IsDiscountPercent = '1';
            $scope.PurchaseForm.IsActive = '1';
        }

        $scope.ListProductsPurchase = [];

        $scope.DiscountForm = {
            CurrentProduct: {},
            IsShowing: false,
            Discount: '0',
            IsDiscountPercent: '1'
        }

        $scope.ResetDiscountForm = function () {
            $scope.DiscountForm.CurrentProduct = {};
            $scope.DiscountForm.IsShowing = false;
            $scope.DiscountForm.Discount = '0';
            $scope.DiscountForm.IsDiscountPercent = '1';
        }

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
            for (var i = 0 ; i < $scope.ListProductsPurchase.length ; i++) {
                if ($scope.ListProductsPurchase[i].ProductId == product.ProductId) {
                    if (product.AllowNegative == '0' && $scope.ListProductsPurchase[i].Quantity == $scope.ListProductsPurchase[i].MaxQuantity) {
                        ShowErrorMessage("Sản phẩm không cho bán âm và còn tồn " + $scope.ListProductsPurchase[i].MaxQuantity + " sản phẩm");
                    }
                    else {
                        $scope.ListProductsPurchase[i].Quantity++;
                    }
                    return;
                }
            }
            var item = {
                Id: "-1",
                PurchaseId: '-1',
                RowNum: $scope.ListProductsPurchase.length + 1,
                ProductId: product.ProductId,
                ProductCode: product.ProductCode,
                ProductName: product.ProductName,
                Price: product.Price,
                Quantity: 1,
                MaxQuantity: product.Quantity,
                RealPrice: product.Price,
                AllowNegative: product.AllowNegative,
                Discount: "0",
                IsDiscountPercent: '1'
            }
            $scope.ListProductsPurchase.push(item);

            $scope.Summarize();
        }

        $scope.ChangeProductQuantity = function (product, num) {
            num = parseInt(product.Quantity) + num;
            if (num <= 0) {
                ShowErrorMessage("Số lượng tối thiểu là 1");
                num = 1;
            }
            else if (product.AllowNegative == '0' && num > product.MaxQuantity) {
                ShowErrorMessage("Sản phẩm không cho bán âm và còn tồn " + product.MaxQuantity + " sản phẩm");
                num = product.MaxQuantity;
            }
            product.Quantity = num;
            //Recalcualte Real Price
            if (product.IsDiscountPercent == '0') {
                product.RealPrice = product.Quantity * (product.Price - product.Discount);
            }
            else {
                product.RealPrice = product.Quantity * parseInt(product.Price * (100 - product.Discount) / 100);
            }

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

        $scope.ShowDiscount = function ($event, product) {
            if ($scope.DiscountForm.CurrentProduct.ProductId == product.ProductId) {
                $scope.DiscountForm.IsShowing = !$scope.DiscountForm.IsShowing;
            }
            else {
                $scope.DiscountForm.IsShowing = true;
            };
            $scope.DiscountForm.CurrentProduct = product;
            $scope.DiscountForm.Discount = product.Discount;
            $scope.DiscountForm.IsDiscountPercent = product.IsDiscountPercent;

            if ($scope.DiscountForm.IsShowing) {
                var position = $($event.currentTarget).position();
                $("#divDiscount").css('top', $event.pageY - $("#divDiscount").height() - 12);
                if (product.ProductId) {
                    //show for specific product
                    $("#divDiscount").css('left', $event.pageX - $("#divDiscount").width() + 40);
                }
                else {
                    //show for purchase
                    $("#divDiscount").css('left', $event.pageX - 2 * $("#divDiscount").width() - 5);
                }
            }
            else {
                $("#divDiscount").css('left', -1000);
                $scope.ResetDiscountForm();
            }
        }

        $scope.SetPercentDiscount = function (percent) {
            $scope.DiscountForm.Discount = percent;
            $scope.DiscountForm.IsDiscountPercent = '1';
            $scope.ChangeDiscount();
        }

        $scope.ChangeDiscount = function () {
            $scope.DiscountForm.Discount = parseFloat($scope.DiscountForm.Discount);
            if ($scope.DiscountForm.Discount < 0) {
                $scope.DiscountForm.Discount = 0
                ShowErrorMessage("Giảm giá không được âm.");
            }
            else if ($scope.DiscountForm.IsDiscountPercent == '1' && $scope.DiscountForm.Discount > 100) {
                $scope.DiscountForm.Discount = 100;
                ShowErrorMessage("Giảm tối đa là 100%.");
            }
            else if ($scope.DiscountForm.IsDiscountPercent == '0' && $scope.DiscountForm.Discount > $scope.DiscountForm.CurrentProduct.Price) {
                $scope.DiscountForm.Discount = $scope.DiscountForm.CurrentProduct.Price;
                ShowErrorMessage("Giảm tối đa giá trị sản phẩm");
            }
            else if (!$scope.DiscountForm.Discount) {
                $scope.DiscountForm.Discount = 0;
            }
            $scope.DiscountForm.CurrentProduct.Discount = $scope.DiscountForm.Discount;
            $scope.DiscountForm.CurrentProduct.IsDiscountPercent = $scope.DiscountForm.IsDiscountPercent;

            if ($scope.DiscountForm.CurrentProduct.ProductId) {
                if ($scope.DiscountForm.IsDiscountPercent == '0') {
                    $scope.DiscountForm.CurrentProduct.RealPrice = $scope.DiscountForm.CurrentProduct.Quantity * ($scope.DiscountForm.CurrentProduct.Price - $scope.DiscountForm.CurrentProduct.Discount);
                }
                else {
                    $scope.DiscountForm.CurrentProduct.RealPrice = $scope.DiscountForm.CurrentProduct.Quantity * parseInt($scope.DiscountForm.CurrentProduct.Price * (100 - $scope.DiscountForm.CurrentProduct.Discount) / 100);
                }
            }

            $scope.Summarize();
        }

        $scope.Summarize = function () {
            var sum = 0;
            var initSum = 0;
            for (var i = 0 ; i < $scope.ListProductsPurchase.length ; i++) {
                var item = $scope.ListProductsPurchase[i];
                sum += parseInt(item.RealPrice);
                initSum += item.Quantity * parseInt(item.Price);
            }
            $scope.PurchaseForm.Price = sum;

            if ($scope.PurchaseForm.IsDiscountPercent == '0') {
                $scope.PurchaseForm.DiscountAmmount = $scope.PurchaseForm.Discount;

            }
            else {
                $scope.PurchaseForm.DiscountAmmount = parseInt($scope.PurchaseForm.Price * $scope.PurchaseForm.Discount / 100);
            }
            $scope.PurchaseForm.SumMoney = $scope.PurchaseForm.Price - $scope.PurchaseForm.DiscountAmmount;
            $scope.PurchaseForm.TotalDiscount = initSum - $scope.PurchaseForm.SumMoney;
            $scope.PurchaseForm.Paid = $scope.PurchaseForm.SumMoney;
            $scope.PurchaseForm.Debt = '0';
        }

        $scope.ChangePaid = function () {
            $scope.PurchaseForm.Paid = parseInt($scope.PurchaseForm.Paid);
            $scope.PurchaseForm.Debt = $scope.PurchaseForm.SumMoney - $scope.PurchaseForm.Paid;
            if ($scope.PurchaseForm.Debt < 0) {
                $scope.PurchaseForm.Debt = '0';
            }
        }

        $scope.ReloadListProducts = function () {
            var len = $scope.ListProductsPurchase.length;
            for (var i = 0 ; i < len; i++) {
                var product = $scope.ProductFormConfig.GetObject($scope.ListProductsPurchase[i].ProductId);
                $scope.ListProductsPurchase[i].Price = product.Price;
                $scope.ListProductsPurchase[i].MaxQuantity = product.Quantity;
                $scope.ListProductsPurchase[i].AllowNegative = product.AllowNegative;
            }
        }

        $scope.SavePurchaseForm = function (status) {
            $scope.ReloadListProducts();
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
            $scope.PurchaseForm.CustomerName = purchase.CustomerName;
            $scope.PurchaseForm.PurchaserName = purchase.PurchaserName;
            $scope.IsShowPurchaseDetail = true;

            //Load Product purchase
            $scope.ReloadGrid('ProductsPurchase');
            $scope.ListProductsPurchase = $scope.DataSet.ProductsPurchase.Data;

            FValidation.ClearAllError();

            var len = $scope.ListProductsPurchase.length;
            for (var i = 0 ; i < len; i++) {
                var item = $scope.ListProductsPurchase[i];

                if (item.IsDiscountPercent == '0') {
                    item.RealPrice = item.Quantity * (item.Price - item.Discount);
                }
                else {
                    item.RealPrice = item.Quantity * parseInt(item.Price * (100 - item.Discount) / 100);
                }

                item.RowNum = i + 1;
            }

            $scope.Summarize();
        }

    }]);