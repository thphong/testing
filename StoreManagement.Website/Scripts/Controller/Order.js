function CheckNumOfProductOrder() {
    var scope = angular.element(document.getElementById("OrderController")).scope();
    var len = scope.ListProductsOrder.length;
    return len > 0;
}

function CheckAllowCredit() {
    var scope = angular.element(document.getElementById("OrderController")).scope();
    var debt = scope.OrderForm.DebtMoney;
    var rule = scope.RULES.ALLOW_CREDIT_SELLING;
    if (debt > 0 && rule != 1) {
        return false;
    }
    return true;
}

mdlCommon.controller('OrderController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('CustomerModalController', { $scope: $scope });
        $controller('ProductListController', { $scope: $scope });
        $controller('PrintController', { $scope: $scope });
        $controller('POSController', { $scope: $scope });

        $scope.AdditionalFilter = {
            OrderType: "1",
            Status: "0",
            ProductGroup: "0"
        };

        $scope.OrderFormConfig = new ObjectDataConfig("T_Trans_Orders", $scope);
        $scope.OrderFormConfig.SetSubTableName("T_Trans_Order_Product");
        $scope.ReturnProductConfig = new ObjectDataConfig("T_Trans_Order_Product_Return", $scope);
        $scope.ProductOrderFormConfig = new ObjectDataConfig("T_Trans_Order_Product", $scope);
        $scope.ProductFormConfig = new ObjectDataConfig("T_Trans_Products", $scope);
        $scope.PaymentFormConfig = new ObjectDataConfig("T_Trans_Payment", $scope);
        

        $scope.OrderFormConfig.CheckCanCreateObject();

        $scope.IsShowOrderDetail = false;
        $scope.IsReturnProducts = false;

        $scope.OrderForm = {
            OrderId: -1,
            OrderCode: "",
            StoreId: "",
            Customer: "",
            CustomerName: "",
            CustomerIsWholeSale: "",
            SoldDate: "",
            Cashier: $scope.CurrentUser,
            CashierName: $scope.CurrentUserName,
            Notes: "",
            OrderStatus: 1,
            PaymentType: 1,
            Price: 0, //sum before discount
            SumMoney: 0,
            Discount: 0,
            DiscountAmmount: 0,
            TotalDiscount: 0,
            DebtMoney: 0,
            ExtraMoney: 0,
            OrginalMoney: 0,
            Paid: 0,
            IsDiscountPercent: 1,
            IsActive: 1,
            PaidForDebt: 0,
            IsEditingPaidForDebt: false,
            Version: 0,
            IsPOS: false,
            ReturnMoney: 0,
            _CanUpdate: true,
            _CanDelete: true
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
            $scope.OrderForm.CashierName = $scope.CurrentUserName;
            $scope.OrderForm.Notes = "";
            $scope.OrderForm.OrderStatus = 1;
            $scope.OrderForm.PaymentType = 1;
            $scope.OrderForm.SumMoney = 0;
            $scope.OrderForm.Price = 0;
            $scope.OrderForm.Discount = 0;
            $scope.OrderForm.DiscountAmmount = 0;
            $scope.OrderForm.TotalDiscount = 0;
            $scope.OrderForm.DebtMoney = 0;
            $scope.OrderForm.ExtraMoney = 0;
            $scope.OrderForm.Paid = 0;
            $scope.OrderForm.IsDiscountPercent = 1;
            $scope.OrderForm.IsActive = 1;
            $scope.OrderForm.PaidForDebt = 0;
            $scope.OrderForm.IsEditingPaidForDebt = false;
            $scope.OrderForm.Version = 0;
            $scope.OrderForm.ReturnMoney = 0;
            $scope.OrderForm._CanUpdate = true;
            $scope.OrderForm._CanDelete = true;
        }

        $scope.ListProductsOrder = [];

        $scope.DiscountForm = {
            CurrentProduct: {},
            IsShowing: false,
            Discount: 0,
            IsDiscountPercent: 1,
            PromotionName: ""
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
            $scope.DataSet.ProductsReturn.TotalItems = 0;
            $scope.IsReturnProducts = false;
        }

        $scope.CloseOrderDetail = function () {
            if ($scope.IsReturnProducts) {
                $scope.IsReturnProducts = false;
            }
            else {
                $scope.IsShowOrderDetail = false;
            }
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
            if (product.AllowNegative == '0' && product.Quantity <= 0) {
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
                        $scope.ListProductsOrder[i].Cost = product.Cost;
                        $scope.ListProductsOrder[i].Price = product.Price;
                        $scope.ListProductsOrder[i].MaxQuantity = product.Quantity;
                        if ($scope.ListProductsOrder[i].IsDiscountPercent == '0') {
                            $scope.ListProductsOrder[i].RealPrice = $scope.ListProductsOrder[i].Quantity * ($scope.ListProductsOrder[i].Price - $scope.ListProductsOrder[i].Discount);
                        }
                        else {
                            $scope.ListProductsOrder[i].RealPrice = $scope.ListProductsOrder[i].Quantity * parseInt($scope.ListProductsOrder[i].Price * (100 - $scope.ListProductsOrder[i].Discount) / 100);
                        }
                    }

                    var item = $scope.ListProductsOrder[i];
                    $scope.ListProductsOrder.splice(i, 1);
                    $scope.ListProductsOrder.splice(0, 0, item);

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
                    Cost: product.Cost,
                    Quantity: 1,
                    MaxQuantity: product.Quantity,
                    RealPrice: product.Price,
                    AllowNegative: product.AllowNegative,
                    Discount: 0,
                    IsDiscountPercent: 1
                }
                $scope.ListProductsOrder.splice(0, 0, item);
            }
            $scope.Summarize(true);

            //Calculate for POS
            $scope.CalCulatePromotion();
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

            $scope.Summarize(true);

            //Calculate for POS
            $scope.CalCulatePromotion();
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

                $scope.Summarize(true);

                //Calculate for POS
                $scope.CalCulatePromotion();
            }
        }

        $scope.ShowDiscount = function ($event, discountObject) {
            if ($scope.DiscountForm.CurrentProduct.ProductId == discountObject.ProductId) {
                $scope.DiscountForm.IsShowing = !$scope.DiscountForm.IsShowing;
            }
            else {
                $scope.DiscountForm.IsShowing = true;
            };
            $scope.DiscountForm.CurrentProduct = discountObject;
            $scope.DiscountForm.Discount = discountObject.Discount;
            $scope.DiscountForm.IsDiscountPercent = discountObject.IsDiscountPercent;

            if ($scope.DiscountForm.IsShowing) {
                var position = $($event.currentTarget).position();
                $("#divDiscount").css('top', $event.pageY - 0.5 * $("#divDiscount").height());
                if (discountObject.ProductId) {
                    //show for specific product
                    $("#divDiscount").css('left', $event.pageX + 15);
                }
                else {
                    //show for order
                    $("#divDiscount").css('left', $event.pageX - $("#divDiscount").width() - 20);
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

            $scope.Summarize(true);
        }

        $scope.Summarize = function (isEditing) {
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
            if (isEditing) {
                $scope.OrderForm.Paid = $scope.OrderForm.SumMoney;
                $scope.OrderForm.DebtMoney = 0;
                $scope.OrderForm.ExtraMoney = 0;
            }
        }

        $scope.ChangePaid = function () {
            $scope.OrderForm.DebtMoney = $scope.OrderForm.SumMoney - GetIntFromCurrency($scope.OrderForm.Paid);
            if ($scope.OrderForm.DebtMoney < 0) {
                $scope.OrderForm.ExtraMoney = -$scope.OrderForm.DebtMoney;
                $scope.OrderForm.DebtMoney = 0;
            }
            else {
                $scope.OrderForm.ExtraMoney = 0;
            }
        }

        $scope.ReloadListProducts = function () {
            var len = $scope.ListProductsOrder.length;

            var configList = new GridViewConfig("");
            configList.GridDataAction = "getall";
            configList.GridDataObject = "T_Trans_Products";
            configList.GridDefinedColums = "Quantity;AllowNegative";

            for (var i = 0 ; i < len; i++) {

                configList.GridFilterCondition = "T_Trans_Products.ProductId = " + $scope.ListProductsOrder[i].ProductId
                                                 + " and StoreId = " + $scope.CurrentStore;

                var productStore = configList.GetListData()[0];
                if (productStore) {
                    $scope.ListProductsOrder[i].MaxQuantity = productStore.Quantity;
                    $scope.ListProductsOrder[i].AllowNegative = productStore.AllowNegative;
                }
            }
        }

        $scope.SaveOrderForm = function (status, hasPrint) {
            $scope.ReloadListProducts();
            if (FValidation.CheckControls("check-order")) {
                $scope.OrderForm.OrderStatus = status;
                $scope.OrderForm.StoreId = $scope.CurrentStore;
                $scope.OrderFormConfig.SetObject($scope.OrderForm);
                $scope.OrderFormConfig.SetListObject($scope.ListProductsOrder);
                var orderId = $scope.OrderFormConfig.SaveComplexObject();
                if (orderId > 0) {

                    ShowSuccessMessage("Đơn hàng được lưu thành công!");
                    $scope.IsShowOrderDetail = false;
                    $scope.OrderForm.OrderId = orderId;

                    if (hasPrint) {
                        PrintForm('ORDER_ADMIN');
                    }
                }
            }
        }

        $scope.ReturnOrder = function () {
            $scope.IsReturnProducts = true;

            var len = $scope.ListProductsOrder.length;
            for (var i = 0 ; i < len; i++) {
                var item = $scope.ListProductsOrder[i];
                item.ReturnQuantity = 0;
            }
        }

        $scope.SaveReturnOrder = function () {
            var listReturn = [];
            
            var len = $scope.ListProductsOrder.length;
            for (var i = 0 ; i < len; i++) {
                var item = $scope.ListProductsOrder[i];
                if (item.ReturnQuantity > 0) {
                    listReturn.push(item);
                }
            }

            if (listReturn.length > 0) {
                $scope.ReturnProductConfig.SetListObject(listReturn);
                var result = $scope.ReturnProductConfig.SaveListObject();
                if (result) {
                    $scope.IsReturnProducts = false;
                    ShowSuccessMessage("Hàng được trả thành công.");
                    $('#returnPOSModal').modal('hide');
                    $scope.ReloadGrid("ProductsOrder");
                    $scope.ReloadGrid("ProductsReturn");
                    $scope.InitListProducts();
                }
            }
            else {
                ShowErrorMessage("Không có hàng hóa nào được trả");
            }
        }
        $scope.ChangeReturnQuantity = function (item) {
            item.ReturnQuantity = parseInt(item.ReturnQuantity);
            if (item.ReturnQuantity < 0) {
                ShowErrorMessage("Số lượng trả không được âm.");
                item.ReturnQuantity = 0;
            }
            if (item.ReturnQuantity > item.Quantity) {
                ShowErrorMessage("Số lượng không được vượt quá số lượng đã mua là " + item.Quantity);
                item.ReturnQuantity = item.Quantity;
            }
            $scope.SummarizeReturnMoney();
        }

        $scope.SummarizeReturnMoney = function () {
            $scope.OrderForm.ReturnMoney = 0;
            var len = $scope.ListProductsOrder.length;
            for (var i = 0 ; i < len; i++) {
                var item = $scope.ListProductsOrder[i];
                if (item.ReturnQuantity > 0 && item.SellPrice > 0) {
                    $scope.OrderForm.ReturnMoney += parseInt(item.ReturnQuantity) * parseFloat(item.SellPrice) / parseInt(item.Quantity);
                }
            }
        }

        $scope.ShowOrderDetail = function (order) {
            //Load Order form
            $scope.IsShowOrderDetail = true;
            $scope.IsReturnProducts = false;
            $scope.GetOrderDetail(order);
            $scope.OrderForm._CanUpdate = order._CanUpdate;
            $scope.OrderForm._CanDelete = order._CanDelete;
            $scope.ReloadGrid("ProductsOrder");
            $scope.ReloadGrid("ProductsReturn");
            $scope.InitListProducts();
        }

        $scope.GetOrderDetail = function (order) {
            $scope.ResetOrderForm();
            var object = $scope.OrderFormConfig.GetObject(order.OrderId);
            $scope.OrderFormConfig.CopyFields(object, $scope.OrderForm);
            $scope.OrderForm.CustomerIsWholeSale = order.CustomerIsWholeSale;
            $scope.OrderForm.CustomerName = order.CustomerName;
            $scope.OrderForm.CashierName = order.CashierName;
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

            $scope.Summarize(false);
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

        $scope.EditPaidForDebt = function () {
            $scope.OrderForm.PaidForDebt = $scope.OrderForm.DebtMoney;
            $scope.OrderForm.IsEditingPaidForDebt = true;
        }

        $scope.CancelPaidForDebt = function () {
            $scope.OrderForm.IsEditingPaidForDebt = false;
        }

        $scope.SavePaidForDebt = function () {
            var paidForDebt = GetIntFromCurrency($scope.OrderForm.PaidForDebt);

            if (FValidation.CheckControls("check-order")) {
                $scope.OrderForm.DebtMoney = GetIntFromCurrency($scope.OrderForm.DebtMoney) - paidForDebt;
                if ($scope.OrderForm.DebtMoney < 0) {
                    $scope.OrderForm.DebtMoney = 0;
                }
                $scope.OrderForm.Paid = GetIntFromCurrency($scope.OrderForm.Paid) + paidForDebt;

                $scope.PaymentForm.OrderId = $scope.OrderForm.OrderId;
                $scope.PaymentForm.Amount = paidForDebt;
                $scope.PaymentForm.PaymentType = $scope.OrderForm.PaymentType;

                $scope.PaymentFormConfig.SetObject($scope.PaymentForm);
                if ($scope.PaymentFormConfig.SaveObject() > 0) {
                    ShowSuccessMessage("Thanh toán nợ thành công.");
                    $scope.OrderForm.IsEditingPaidForDebt = false;
                }
            }

        }

        //POS

        $scope.PrintOrderAdmin = function (order, template) {

            $scope.GetOrderDetail(order);
            $scope.ReloadGrid("ProductsOrder");
            $scope.InitListProducts();

            //print
            $scope.PrintForm(template);

        }

        $scope.PrintForm = function (template) {
            $scope.GetListPrintTerm("Order");
            $scope.GetPrintTemplate(template, $scope.ParentStore);

            setTimeout(function () {
                $scope.PrintData("divPrint");
            }, 100);
        }

    }]);