﻿$(document).ready(function () {
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
                var scope = angular.element(document.getElementById("OrderController")).scope();
                scope.$apply(function () {
                    scope.SelectProduct(ui.item);
                });
                $("#txtSearchProduct").val("");
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


mdlCommon.controller('OrderController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('CustomerModalController', { $scope: $scope });

        $scope.AdditionalFilter = {
            OrderType: "1",
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
            $scope.ReloadGrid('Orders');
        }

        $scope.OrderFormConfig = new ObjectDataConfig("T_Trans_Orders");
        $scope.ProductOrderFormConfig = new ObjectDataConfig("T_Trans_Order_Product");

        $scope.IsShowOrderDetail = false;
        $scope.IsEditingOrderDetail = false;

        $scope.OrderForm = {
            OrderId: "-1",
            OrderCode: "",
            Customer: "",
            CustomerName: "",
            CustomerIsWholeSale: "",
            SoldDate: "",
            Cashier: $scope.CurrentUser,
            Notes: "",
            PaymentType: '1',
            Price: '0', //sum before discount
            SumMoney: '0',
            Discount: '0',
            DiscountAmmount: '0',
            TotalDiscount: '0',
            DebtMoney: '0',
            Paid: '0',
            IsDiscountPercent: '1'
        };

        $scope.ResetOrderForm = function () {
            $scope.OrderForm.OrderId = "-1";
            $scope.OrderForm.OrderCode = "";
            $scope.OrderForm.Customer = "";
            $scope.OrderForm.CustomerName = "";
            $scope.OrderForm.CustomerIsWholeSale = "";
            $scope.OrderForm.SoldDate = "";
            $scope.OrderForm.Cashier = $scope.CurrentUser;
            $scope.OrderForm.Notes = "";
            $scope.OrderForm.PaymentType = '1';
            $scope.OrderForm.SumMoney = '0';
            $scope.OrderForm.Price = '0';
            $scope.OrderForm.Discount = '0';
            $scope.OrderForm.DiscountAmmount = '0';
            $scope.OrderForm.TotalDiscount = '0';
            $scope.OrderForm.DebtMoney = '0';
            $scope.OrderForm.Paid = '0';
            $scope.OrderForm.IsDiscountPercent = '1';    
        }

        $scope.ListProductsOrder = [];

        $scope.DiscountForm = {
            CurrentProduct: {},
            IsShowing: false,
            Discount: '0',
            IsDiscountPercent: '1'
        }

        $scope.ResetDiscountForm = function() {
            $scope.DiscountForm.CurrentProduct = {};
            $scope.DiscountForm.IsShowing = false;
            $scope.DiscountForm.Discount = '0';
            $scope.DiscountForm.IsDiscountPercent = '1';
        }

        $scope.AddOrder = function () {
            $scope.IsShowOrderDetail = true;
            $scope.IsEditingOrderDetail = true;
            FValidation.ClearAllError();
            $scope.ResetOrderForm();
        }

        $scope.CloseOrderDetail = function () {
            if ($scope.IsEditingOrderDetail && $scope.OrderForm.OrderId != "-1") {
                $scope.IsEditingOrderDetail = false;
            }
            else {
                $scope.IsShowOrderDetail = false;
            }
        }

        $scope.DeleteOrder = function (order) {
            if (confirm("Bạn có muốn xóa đơn hàng " + order.OrderCode + "?")) {
                if ($scope.OrderFormConfig.DeleteObject(order.OrderCode, "OrderCode")) {
                    $scope.ReloadGrid('Orders');
                    ShowSuccessMessage("Đơn hàng được xóa thành công!");
                }
            }
        }

        $scope.SelectProduct = function (product) {
            for (var i = 0 ; i < $scope.ListProductsOrder.length ; i++) {
                if ($scope.ListProductsOrder[i].ProductId == product.ProductId) {
                    if (product.AllowNegative == '0' && $scope.ListProductsOrder[i].Quantity == $scope.ListProductsOrder[i].MaxQuantity) {
                        ShowErrorMessage("Sản phẩm không cho bán âm và còn tồn " + $scope.ListProductsOrder[i].MaxQuantity + " sản phẩm");
                    }
                    else {
                        $scope.ListProductsOrder[i].Quantity++;
                    }
                    return;
                }
            }
            var item = {
                Id: "-1",
                RowNum: $scope.ListProductsOrder.length + 1,
                ProductId: product.ProductId,
                ProductCode: product.ProductCode,
                ProductName: product.ProductName,
                Price: product.Price,
                Quantity: 1,
                MaxQuantity: product.Quantity,
                RealPrice: product.Price,
                AllowNegative: product.AllowNegative,
                Discount: "0", 
                IsDiscountPercent : '1'
            }
            $scope.ListProductsOrder.push(item);

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

        $scope.DeleteProductOrder = function (product) {
            if (confirm("Bạn có muốn xóa sản phẩm '" + product.ProductCode + " - " + product.ProductName + "' trong đơn hàng?")) {

                if (product.Id != "-1") {
                    $scope.ProductOrderFormConfig.DeleteObject(product.Id);
                }

                for (var i = 0 ; i < $scope.ListProductsOrder.length ; i++) {
                    if ($scope.ListProductsOrder[i].ProductId == product.ProductId) {
                        $scope.ListProductsOrder.splice(i, 1);
                        break;
                    }
                }

                ShowSuccessMessage("Sản phẩm được xóa khỏi đơn hàng thành công!");
            }
        }

        $scope.ShowDiscount = function ($event, product) {
            if ($scope.DiscountForm.CurrentProduct.ProductId == product.ProductId)
            {
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
                    //show for order
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
            if ($scope.DiscountForm.Discount < 0)
            {
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
            else if (!$scope.DiscountForm.Discount)
            {
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
            for (var i = 0 ; i < $scope.ListProductsOrder.length ; i++) {
                var item = $scope.ListProductsOrder[i];
                sum += parseInt(item.RealPrice);
                initSum += item.Quantity * parseInt(item.Price);
            }
            $scope.OrderForm.Price = sum;

            if ($scope.OrderForm.IsDiscountPercent == '0') {
                $scope.OrderForm.DiscountAmmount = $scope.OrderForm.Discount;

            }
            else {
                $scope.OrderForm.DiscountAmmount = parseInt($scope.OrderForm.Price * $scope.OrderForm.Discount / 100);
            }
            $scope.OrderForm.SumMoney = $scope.OrderForm.Price - $scope.OrderForm.DiscountAmmount;
            $scope.OrderForm.TotalDiscount = initSum - $scope.OrderForm.SumMoney;
            $scope.OrderForm.Paid = $scope.OrderForm.SumMoney;
            $scope.OrderForm.DebtMoney = 0;
        }

        $scope.ChangePaid = function()
        {
            $scope.OrderForm.Paid = parseInt($scope.OrderForm.Paid);
            $scope.OrderForm.DebtMoney = $scope.OrderForm.SumMoney - $scope.OrderForm.Paid;
            if ($scope.OrderForm.DebtMoney < 0) {
                $scope.OrderForm.DebtMoney = 0;
            }
        }
        /*
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

        $scope.ShowSupplierDetail = function (supplier) {

            var object = $scope.SupplierFormConfig.GetObject(supplier.SupplierCode, 'SupplierCode');
            $scope.SupplierFormConfig.ConvertFieldsToString(object, $scope.SupplierForm);
            $scope.IsShowSupplierDetail = true;
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
        }*/

    }]);