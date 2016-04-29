
function CheckNumOfProduct() {
    var scope = angular.element(document.getElementById("OrderController")).scope();
    var len = scope.ListProductsOrder.length;
    return len > 0;
}

mdlCommon.controller('OrderController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('CustomerModalController', { $scope: $scope });
        $controller('ProductListController', { $scope: $scope });

        $scope.AdditionalFilter = {
            OrderType: "1",
            Status: "0"
        };

        $scope.OrderFormConfig = new ObjectDataConfig("T_Trans_Orders", $scope);
        $scope.ProductOrderFormConfig = new ObjectDataConfig("T_Trans_Order_Product", $scope);
        $scope.ProductFormConfig = new ObjectDataConfig("T_Trans_Products", $scope);

        $scope.IsShowOrderDetail = false;

        $scope.OrderForm = {
            OrderId: -1,
            OrderCode: "",
            StoreId: "",
            Customer: "",
            CustomerName: "",
            CustomerIsWholeSale: "",
            SoldDate: "",
            Cashier: $scope.CurrentUser,
            CashierName: "",
            Notes: "",
            OrderStatus: 1,
            PaymentType: 1,
            Price: 0, //sum before discount
            SumMoney: 0,
            Discount: 0,
            DiscountAmmount: 0,
            TotalDiscount: 0,
            DebtMoney: 0,
            Paid: 0,
            IsDiscountPercent: 1,
            IsActive: 1,
            PaidForDebt: 0,
            IsEditingPaidForDebt: false,
            _CanUpdate: true,
            _CanDelete : true
        };

        $scope.ResetOrderForm = function () {
            $scope.OrderForm.OrderId = -1;
            $scope.OrderForm.OrderCode = "";
            $scope.OrderForm.StoreId = "";
            $scope.OrderForm.Customer = "";
            $scope.OrderForm.CustomerName = "";
            $scope.OrderForm.CustomerIsWholeSale = "";
            $scope.OrderForm.SoldDate = "";
            $scope.OrderForm.Cashier = $scope.CurrentUser;
            $scope.OrderForm.CashierName = "";
            $scope.OrderForm.Notes = "";
            $scope.OrderForm.OrderStatus = 1;
            $scope.OrderForm.PaymentType = 1;
            $scope.OrderForm.SumMoney = 0;
            $scope.OrderForm.Price = 0;
            $scope.OrderForm.Discount = 0;
            $scope.OrderForm.DiscountAmmount = 0;
            $scope.OrderForm.TotalDiscount = 0;
            $scope.OrderForm.DebtMoney = 0;
            $scope.OrderForm.Paid = 0;
            $scope.OrderForm.IsDiscountPercent = 1;
            $scope.OrderForm.IsActive = 1;
            $scope.OrderForm.PaidForDebt = 0;
            $scope.OrderForm.IsEditingPaidForDebt = false;
            $scope.OrderForm._CanUpdate = true;
            $scope.OrderForm._CanDelete = true;
        }

        $scope.ListProductsOrder = [];

        $scope.DiscountForm = {
            CurrentProduct: {},
            IsShowing: false,
            Discount: 0,
            IsDiscountPercent: 1
        }

        $scope.ResetDiscountForm = function () {
            $scope.DiscountForm.CurrentProduct = {};
            $scope.DiscountForm.IsShowing = false;
            $scope.DiscountForm.Discount = 0;
            $scope.DiscountForm.IsDiscountPercent = 1;
        }

        $scope.AddOrder = function () {
            $scope.IsShowOrderDetail = true;
            FValidation.ClearAllError();
            $scope.ResetOrderForm();
            $scope.ListProductsOrder = [];
        }

        $scope.CloseOrderDetail = function () {
            $scope.IsShowOrderDetail = false;
        }


        $scope.DeleteOrder = function (order) {
            if (confirm("Bạn có muốn xóa đơn hàng " + order.OrderCode + "?")) {
                if ($scope.OrderFormConfig.DeleteObject(order.OrderId)) {
                    $scope.ReloadGrid('Orders');
                    ShowSuccessMessage("Đơn hàng được xóa thành công!");
                }
            }
        }

        $scope.SelectProduct = function (product) {
            if (product.AllowNegative == '0' && product.Quantity <= 0)
            {
                ShowErrorMessage("Sản phẩm không cho bán âm và không còn sản phẩm trong kho.");
                return;
            }
            var hasExist = false;
            for (var i = 0 ; i < $scope.ListProductsOrder.length ; i++) {
                if ($scope.ListProductsOrder[i].ProductId == product.ProductId) {
                    if (product.AllowNegative == '0' && $scope.ListProductsOrder[i].Quantity == $scope.ListProductsOrder[i].MaxQuantity) {
                        ShowErrorMessage("Sản phẩm không cho bán âm và còn tồn " + $scope.ListProductsOrder[i].MaxQuantity + " sản phẩm");
                    }
                    else {
                        $scope.ListProductsOrder[i].Quantity++;
                        if ($scope.ListProductsOrder[i].IsDiscountPercent == '0') {
                            $scope.ListProductsOrder[i].RealPrice = $scope.ListProductsOrder[i].Quantity * ($scope.ListProductsOrder[i].Price - $scope.ListProductsOrder[i].Discount);
                        }
                        else {
                            $scope.ListProductsOrder[i].RealPrice = $scope.ListProductsOrder[i].Quantity * parseInt($scope.ListProductsOrder[i].Price * (100 - $scope.ListProductsOrder[i].Discount) / 100);
                        }
                    }
                    hasExist = true;
                    break;
                }
            }
            if (!hasExist) {
                var item = {
                    Id: -1,
                    OrderId: $scope.OrderForm.OrderId,
                    RowNum: $scope.ListProductsOrder.length + 1,
                    ProductId: product.ProductId,
                    ProductCode: product.ProductCode,
                    ProductName: product.ProductName,
                    Price: product.Price,
                    Quantity: 1,
                    MaxQuantity: product.Quantity,
                    RealPrice: product.Price,
                    AllowNegative: product.AllowNegative,
                    Discount: 0,
                    IsDiscountPercent: 1
                }
                $scope.ListProductsOrder.push(item);
            }
            $scope.Summarize();
        }

        $scope.ChangeProductQuantity = function (product, num) {
            num = parseInt(product.Quantity) + num;
            if (num <= 0) {
                ShowErrorMessage("Số lượng tối thiểu là 1");
                num = 1;
            }
            else if (product.AllowNegative == 0 && num > product.MaxQuantity) {
                ShowErrorMessage("Sản phẩm không cho bán âm và còn tồn " + product.MaxQuantity + " sản phẩm");
                num = product.MaxQuantity;
            }
            product.Quantity = num;
            //Recalcualte Real Price
            if (product.IsDiscountPercent == 0) {
                product.RealPrice = product.Quantity * (product.Price - product.Discount);
            }
            else {
                product.RealPrice = product.Quantity * parseInt(product.Price * (100 - product.Discount) / 100);
            }

            $scope.Summarize();
        }

        $scope.DeleteProductOrder = function (product) {
            if (confirm("Bạn có muốn xóa sản phẩm '" + product.ProductCode + " - " + product.ProductName + "' trong đơn hàng?")) {

                if (product.Id != -1) {
                    $scope.ProductOrderFormConfig.HardDeleteObject(product.Id);
                }

                for (var i = 0 ; i < $scope.ListProductsOrder.length ; i++) {
                    if ($scope.ListProductsOrder[i].ProductId == product.ProductId) {
                        $scope.ListProductsOrder.splice(i, 1);
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
            $scope.DiscountForm.IsDiscountPercent = 1;
            $scope.ChangeDiscount();
        }

        $scope.ChangeDiscount = function () {
            $scope.DiscountForm.Discount = parseFloat($scope.DiscountForm.Discount);
            if ($scope.DiscountForm.Discount < 0) {
                $scope.DiscountForm.Discount = 0
                ShowErrorMessage("Giảm giá không được âm.");
            }
            else if ($scope.DiscountForm.IsDiscountPercent == 1 && $scope.DiscountForm.Discount > 100) {
                $scope.DiscountForm.Discount = 100;
                ShowErrorMessage("Giảm tối đa là 100%.");
            }
            else if ($scope.DiscountForm.IsDiscountPercent == 0 && $scope.DiscountForm.Discount > $scope.DiscountForm.CurrentProduct.Price) {
                $scope.DiscountForm.Discount = $scope.DiscountForm.CurrentProduct.Price;
                ShowErrorMessage("Giảm tối đa giá trị sản phẩm");
            }
            else if (!$scope.DiscountForm.Discount) {
                $scope.DiscountForm.Discount = 0;
            }
            $scope.DiscountForm.CurrentProduct.Discount = $scope.DiscountForm.Discount;
            $scope.DiscountForm.CurrentProduct.IsDiscountPercent = $scope.DiscountForm.IsDiscountPercent;

            if ($scope.DiscountForm.CurrentProduct.ProductId) {
                if ($scope.DiscountForm.IsDiscountPercent == 0) {
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

            if ($scope.OrderForm.IsDiscountPercent == 0) {
                $scope.OrderForm.DiscountAmmount = $scope.OrderForm.Discount;

            }
            else {
                $scope.OrderForm.DiscountAmmount = parseInt($scope.OrderForm.Price * $scope.OrderForm.Discount / 100);
            }
            $scope.OrderForm.SumMoney = $scope.OrderForm.Price - $scope.OrderForm.DiscountAmmount;
            $scope.OrderForm.TotalDiscount = initSum - $scope.OrderForm.SumMoney;
            //$scope.OrderForm.Paid = $scope.OrderForm.SumMoney;
            $scope.OrderForm.DebtMoney = $scope.OrderForm.SumMoney - $scope.OrderForm.Paid;
        }

        $scope.ChangePaid = function () {
            $scope.OrderForm.Paid = parseInt($scope.OrderForm.Paid);
            $scope.OrderForm.DebtMoney = $scope.OrderForm.SumMoney - $scope.OrderForm.Paid;
            if ($scope.OrderForm.DebtMoney < 0) {
                $scope.OrderForm.DebtMoney = 0;
            }
        }

        $scope.ReloadListProducts = function () {
            var len = $scope.ListProductsOrder.length;

            var configList = new GridViewConfig("");
            configList.GridDataAction = "getall";
            configList.GridDataObject = "T_Trans_Product_Store";
            configList.GridDefinedColums = "Quantity;AllowNegative";

            for (var i = 0 ; i < len; i++) {

                configList.GridFilterCondition = "ProductId = " + $scope.ListProductsOrder[i].ProductId
                                                 + " and StoreId = " + $scope.CurrentStore;

                var productStore = configList.GetListData()[0];
                if (productStore) {
                    $scope.ListProductsOrder[i].MaxQuantity = productStore.Quantity;
                    $scope.ListProductsOrder[i].AllowNegative = productStore.AllowNegative;
                }
            }
        }

        $scope.SaveOrderForm = function (status) {
            $scope.ReloadListProducts();
            if (FValidation.CheckControls("check-order")) {
                $scope.OrderForm.OrderStatus = status;
                $scope.OrderForm.StoreId = $scope.CurrentStore;
                $scope.OrderFormConfig.SetObject($scope.OrderForm);
                var orderId = $scope.OrderFormConfig.SaveObject();
                if (orderId > 0) {

                    if ($scope.OrderForm.OrderId == -1) {
                        var len = $scope.ListProductsOrder.length;
                        for (var i = 0 ; i < len; i++) {
                            $scope.ListProductsOrder[i].OrderId = orderId;
                        }
                    }

                    $scope.ProductOrderFormConfig.SetListObject($scope.ListProductsOrder);
                    var result = $scope.ProductOrderFormConfig.SaveListObject();

                    if (result) {
                        ShowSuccessMessage("Đơn hàng được lưu thành công!");
                        //$scope.ReloadGrid('Orders');
                        $scope.IsShowOrderDetail = false;
                    }
                    else if ($scope.OrderForm.OrderId == -1) {

                        $scope.OrderFormConfig.HardDeleteObject(orderId);
                    }
                }
            }
        }


        $scope.ShowOrderDetail = function (order) {
            //Load Order form
            //$scope.OrderFormConfig.SetObject($scope.OrderForm);
            $scope.ResetOrderForm();
            var object = $scope.OrderFormConfig.GetObject(order.OrderId);
            $scope.OrderFormConfig.ConvertFieldsToString(object, $scope.OrderForm);
            $scope.OrderForm.CustomerIsWholeSale = order.CustomerIsWholeSale;
            $scope.OrderForm.CustomerName = order.CustomerName;
            $scope.OrderForm.CashierName = order.CashierName;
            $scope.OrderForm._CanUpdate = order._CanUpdate;
            $scope.OrderForm._CanDelete = order._CanDelete;
            $scope.IsShowOrderDetail = true;

            //FValidation.ClearAllError();
        }

        $scope.InitListProducts = function () {
            $scope.ListProductsOrder = $scope.DataSet.ProductsOrder.Data;
            var len = $scope.ListProductsOrder.length;
            for (var i = 0 ; i < len; i++) {
                var item = $scope.ListProductsOrder[i];

                if (item.IsDiscountPercent == 0) {
                    item.RealPrice = item.Quantity * (item.Price - item.Discount);
                }
                else {
                    item.RealPrice = item.Quantity * parseInt(item.Price * (100 - item.Discount) / 100);
                }

                item.RowNum = i + 1;
            }

            $scope.Summarize();
        }

        $scope.ExposeFunctionAfterSavingCustomer = function () {
            $scope.OrderForm.Customer = $scope.CustomerForm.CustomerId;
            $scope.OrderForm.CustomerName = $scope.CustomerForm.CustomerName;
            $scope.OrderForm.CustomerIsWholeSale = $scope.CustomerForm.IsWholeSale;
        }

        //Paid for Debt
        $scope.PaymentForm = {
            OrderId: "",
            Amount: "",
            IsActive: 1,
            PaymentType: 1,
            StoreId: $scope.CurrentStore
        }

        $scope.PaymentFormConfig = new ObjectDataConfig("T_Trans_Payment", $scope);

        $scope.EditPaidForDebt = function () {
            $scope.OrderForm.PaidForDebt = $scope.OrderForm.DebtMoney;
            $scope.OrderForm.IsEditingPaidForDebt = true;
        }

        $scope.CancelPaidForDebt = function () {
            $scope.OrderForm.IsEditingPaidForDebt = false;
        }

        $scope.SavePaidForDebt = function () {
            $scope.OrderForm.PaidForDebt = parseInt($scope.OrderForm.PaidForDebt);
            if ($scope.OrderForm.PaidForDebt > $scope.OrderForm.DebtMoney) {
                ShowErrorMessage("Số tiền trả lớn hơn số tiền nợ.");
            }
            else {
                if (FValidation.CheckControls("check-order")) {
                    $scope.OrderForm.DebtMoney = parseInt($scope.OrderForm.DebtMoney) - $scope.OrderForm.PaidForDebt;
                    $scope.OrderForm.Paid = parseInt($scope.OrderForm.Paid) + $scope.OrderForm.PaidForDebt;

                    $scope.PaymentForm.OrderId = $scope.OrderForm.OrderId;
                    $scope.PaymentForm.Amount = $scope.OrderForm.PaidForDebt;
                    $scope.PaymentForm.PaymentType = $scope.OrderForm.PaymentType;

                    $scope.PaymentFormConfig.SetObject($scope.PaymentForm);
                    if ($scope.PaymentFormConfig.SaveObject() > 0) {
                        ShowSuccessMessage("Thanh toán nợ thành công.");
                        $scope.OrderForm.IsEditingPaidForDebt = false;
                    }
                }
            }
        }

    }]);