
function CheckNumOfProductPurchase() {
    var scope = angular.element(document.getElementById("PurchaseController")).scope();
    var len = scope.ListProductsPurchase.length;
    return len > 0;
}

mdlCommon.controller('PurchaseController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('SupplierModalController', { $scope: $scope });
        $controller('ProductListController', { $scope: $scope });
        $controller('PrintController', { $scope: $scope });

        $scope.AdditionalFilter = {
            PurchaseType: "1",
            Status: "0"
        };

        $scope.PurchaseFormConfig = new ObjectDataConfig("T_Trans_Purchase", $scope);
        $scope.PurchaseFormConfig.SetSubTableName("T_Trans_Purchase_Product");
        $scope.ProductPurchaseFormConfig = new ObjectDataConfig("T_Trans_Purchase_Product", $scope);
        $scope.PurchaseFormConfig.CheckCanCreateObject();

        $scope.IsShowPurchaseDetail = false;

        $scope.PurchaseForm = {
            PurchaseId: -1,
            PurchaseCode: "",
            StoreId: $scope.CurrentStore,
            SupplierId: "",
            SupplierName: "",
            PurchaseDate: "",
            Purchaser: $scope.CurrentUser,
            PurchaserName: "",
            Notes: "",
            StatusId: 1,
            PaymentType: 1,
            Price: 0, //sum before tax
            SumMoney: 0,
            SumTax: 0,
            Debt: 0,
            PaidForDebt: 0,
            IsEditingPaidForDebt: false,
            Paid: 0,
            IsActive: 1,
            _CanUpdate: true,
            _CanDelete: true,
            Version: 0
        };

        $scope.ResetPurchaseForm = function () {
            $scope.PurchaseForm.PurchaseId = -1;
            $scope.PurchaseForm.PurchaseCode = "";
            $scope.PurchaseForm.StoreId = $scope.CurrentStore;
            $scope.PurchaseForm.SupplierId = "";
            $scope.PurchaseForm.SupplierName = "";
            $scope.PurchaseForm.PurchaseDate = "";
            $scope.PurchaseForm.Purchaser = $scope.CurrentUser;
            $scope.PurchaseForm.PurchaserName = "";
            $scope.PurchaseForm.Notes = "";
            $scope.PurchaseForm.StatusId = 1;
            $scope.PurchaseForm.PaymentType = 1;
            $scope.PurchaseForm.SumMoney = 0;
            $scope.PurchaseForm.SumTax = 0;
            $scope.PurchaseForm.Price = 0;
            $scope.PurchaseForm.Debt = 0;
            $scope.PurchaseForm.Paid = 0;
            $scope.PurchaseForm.IsActive = 1;
            $scope.PurchaseForm.PaidForDebt = 0;
            $scope.PurchaseForm.IsEditingPaidForDebt = false;
            $scope.PurchaseForm._CanUpdate = true;
            $scope.PurchaseForm._CanDelete = true;
            $scope.PurchaseForm.Version = 0;
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
                    Id: -1,
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

                if (product.Id != -1) {
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
            if ($scope.PurchaseForm.Debt < 0) {
                $scope.PurchaseForm.Debt = 0;
            }
        }

        $scope.ChangePaid = function () {
            $scope.PurchaseForm.Debt = $scope.PurchaseForm.SumMoney - GetIntFromCurrency($scope.PurchaseForm.Paid);
            if ($scope.PurchaseForm.Debt < 0) {
                $scope.PurchaseForm.Debt = 0;
            }
        }

        $scope.SavePurchaseForm = function (status) {
            if (FValidation.CheckControls("check-purchase")) {
                $scope.PurchaseForm.StatusId = status;
                $scope.PurchaseForm.StoreId = $scope.CurrentStore;
                $scope.PurchaseFormConfig.SetObject($scope.PurchaseForm);
                $scope.PurchaseFormConfig.SetListObject($scope.ListProductsPurchase);
                //PurchaseFormConfig
                var purchaseId = $scope.PurchaseFormConfig.SaveComplexObject();
                if (purchaseId > 0) {
                    ShowSuccessMessage("Đơn hàng được lưu thành công!");
                    $scope.IsShowPurchaseDetail = false;
                }
            }
        }


        $scope.ShowPurchaseDetail = function (purchase) {
            //Load purchase form
            $scope.GetPurchaseDetail(purchase);
            $scope.IsShowPurchaseDetail = true;
            $scope.PurchaseForm._CanUpdate = purchase._CanUpdate;
            $scope.PurchaseForm._CanDelete = purchase._CanDelete;
            //Load Product purchase
            //$scope.ReloadGrid('ProductsPurchase');
            //FValidation.ClearAllError();
        }

        $scope.GetPurchaseDetail = function (purchase) {
            $scope.PurchaseFormConfig.SetObject($scope.PurchaseForm);
            var object = $scope.PurchaseFormConfig.GetObject(purchase.PurchaseId);
            $scope.PurchaseFormConfig.CopyFields(object, $scope.PurchaseForm);
            $scope.PurchaseForm.SupplierName = purchase.SupplierName;
            $scope.PurchaseForm.PurchaserName = purchase.PurchaserName;
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

        //Paid for Debt
        $scope.PaymentForm = {
            PurchaseId: "",
            Amount: "",
            IsActive: 1,
            PaymentType: 1,
            StoreId: $scope.CurrentStore
        }

        $scope.PaymentFormConfig = new ObjectDataConfig("T_Trans_Purchase_Payment", $scope);

        $scope.EditPaidForDebt = function () {
            $scope.PurchaseForm.PaidForDebt = $scope.PurchaseForm.Debt;
            $scope.PurchaseForm.IsEditingPaidForDebt = true;
        }

        $scope.CancelPaidForDebt = function () {
            $scope.PurchaseForm.IsEditingPaidForDebt = false;
        }

        $scope.SavePaidForDebt = function () {
            var paidForDebt = GetIntFromCurrency($scope.PurchaseForm.PaidForDebt);

            if (FValidation.CheckControls("check-purchase")) {
                $scope.PurchaseForm.Debt = GetIntFromCurrency($scope.PurchaseForm.Debt) - paidForDebt;
                if ($scope.PurchaseForm.Debt < 0) {
                    $scope.PurchaseForm.Debt = 0;
                }
                $scope.PurchaseForm.Paid = GetIntFromCurrency($scope.PurchaseForm.Paid) + paidForDebt;

                $scope.PaymentForm.PurchaseId = $scope.PurchaseForm.PurchaseId;
                $scope.PaymentForm.Amount = paidForDebt;
                $scope.PaymentForm.PaymentType = $scope.PurchaseForm.PaymentType;

                $scope.PaymentFormConfig.SetObject($scope.PaymentForm);
                if ($scope.PaymentFormConfig.SaveObject() > 0) {
                    ShowSuccessMessage("Thanh toán nợ thành công.");
                    $scope.PurchaseForm.IsEditingPaidForDebt = false;
                }
            }
        }

        $scope.PrintPurchase = function (purchase) {
            $scope.GetPurchaseDetail(purchase);
            $scope.ReloadGrid("ProductsPurchase");
            $scope.InitListProducts();

            //print
            $scope.PrintForm();

        }

        $scope.PrintForm = function () {
            $scope.GetListPrintTerm("Purchase");
            $scope.GetPrintTemplate("PURCHASE");

            setTimeout(function () {
                $scope.PrintData("divPrint");
            }, 100);
        }
    }]);