function CheckNumOfProduct() {
    var scope = angular.element(document.getElementById("PrintProductBarcodeController")).scope();
    var len = scope.ListProducts.length;
    return len > 0;
}

mdlCommon.controller('PrintProductBarcodeController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('ProductListController', { $scope: $scope });

        //Thông tin tem
        $scope.ItemInfo = {};
        $scope.ItemInfo.Option = "4";
        $scope.ItemInfo.IsShowPrice = true;
        $scope.ItemInfo.IsShowProductName = true;

        $scope.ItemInfo.PrintSize = "3";

        $scope.$watch('ItemInfo.Option', function () {
            switch ($scope.ItemInfo.Option) {
                case "1": //show barcode only
                    $scope.ItemInfo.IsShowPrice = false;
                    $scope.ItemInfo.IsShowProductName = false;
                    break;
                case "2": //barcode and productname
                    $scope.ItemInfo.IsShowPrice = false;
                    $scope.ItemInfo.IsShowProductName = true;
                    break;
                case "3": //barcode and price
                    $scope.ItemInfo.IsShowPrice = true;
                    $scope.ItemInfo.IsShowProductName = false;
                    break;
                case "4": //all
                    $scope.ItemInfo.IsShowPrice = true;
                    $scope.ItemInfo.IsShowProductName = true;
                    break;
                default:
                    $scope.ItemInfo.Option ="4";
            }
        });

        //khổ in
        
        $scope.$watch('ItemInfo.PrintSize', function () {

        });

        //=====================
        $scope.NumItems = 0;
        $scope.ListProducts = [];

        $scope.SelectProduct = function (product) {
            if (product.AllowNegative == '0' && product.Quantity <= 0) {
                ShowErrorMessage("Sản phẩm không cho bán âm và không còn sản phẩm trong kho.");
                return;
            }
            var hasExist = false;
            for (var i = 0 ; i < $scope.ListProducts.length ; i++) {
                if ($scope.ListProducts[i].ProductId == product.ProductId) {
                    if (product.AllowNegative == '0' && $scope.ListProducts[i].Quantity == $scope.ListProducts[i].MaxQuantity) {
                        ShowErrorMessage("Sản phẩm không cho bán âm và còn tồn " + $scope.ListProducts[i].MaxQuantity + " sản phẩm");
                    }
                    else {
                        $scope.ListProducts[i].Quantity++;
                        $scope.ListProducts[i].Cost = product.Cost;
                        $scope.ListProducts[i].Price = product.Price;
                        $scope.ListProducts[i].MaxQuantity = product.Quantity;
                    }

                    var item = $scope.ListProducts[i];
                    $scope.ListProducts.splice(i, 1);
                    $scope.ListProducts.splice(0, 0, item);

                    hasExist = true;
                    break;
                }
            }
            if (!hasExist) {
                var item = {
                    Id: -1,
                    RowNum: $scope.ListProducts.length + 1,
                    ProductId: product.ProductId,
                    ProductCode: product.ProductCode,
                    ProductName: product.ProductName,
                    Price: product.Price,
                    Quantity: 1,

                    Cost: product.Cost,
                    MaxQuantity: product.Quantity,
                    AllowNegative: product.AllowNegative,
                }
                $scope.ListProducts.splice(0, 0, item);
            }

            $scope.Summarize();

        }

        $scope.Summarize = function () {
            var countProduct = 0;
            for (var i = 0 ; i < $scope.ListProducts.length ; i++) {
                var item = $scope.ListProducts[i];
                if (item.Quantity){
                    countProduct += parseInt(item.Quantity);
                }
            }
            $scope.NumItems = countProduct;
        }

        $scope.DeleteProduct = function (product) {  
            for (var i = 0 ; i < $scope.ListProducts.length ; i++) {
                if ($scope.ListProducts[i].ProductId == product.ProductId) {
                    $scope.ListProducts.splice(i, 1);
                    break;
                }
            }
            $scope.Summarize();
        }
        
        $scope.quantityChange = function (scope, $event) {
            var target = scope.target;
            $scope.Summarize();
        }

        //======================================
        $scope.CreateBarcodePDF = function () {
            if ($scope.ListProducts.length == 0 || $scope.NumItems==0) {
                ShowErrorMessage("Chưa chọn hàng hóa để in mã vạch");
                return null;
            }
            //========================
            var result = null;
            var paras = {
                printSize: $scope.ItemInfo.PrintSize,
                itemInfo: $scope.ItemInfo.Option,
                list : $scope.ListProducts
            };

            var result = AjaxSync(g_createProductBarcodePDF, JSON.stringify(paras));
            return result;
        }

        $scope.DownloadProductBarcode = function () {
            var url_pdf = $scope.CreateBarcodePDF();
            if (url_pdf)
                window.location = url_pdf;
        }

        $scope.PrintProductBarcode = function () {
            var url_pdf = $scope.CreateBarcodePDF();
            if (url_pdf) {
                var wnd = window.open(url_pdf);
                setTimeout(function () {
                    wnd.print();
                }, 100);
            }
        }
    }
]);