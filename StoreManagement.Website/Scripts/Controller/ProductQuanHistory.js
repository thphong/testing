
mdlCommon.controller('ProductQuanHistoryController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {

        $scope.ProductQuanHistoryForm = {
            ProductId: "-1",
            ProductCode: "",
            ProductName: "",
            Quantity: "0"
        };

        $scope.SetProductQuanHistoryForm = function (product) {
            $scope.ProductQuanHistoryForm.ProductId = product.ProductId;
            $scope.ProductQuanHistoryForm.ProductCode = product.ProductCode;
            $scope.ProductQuanHistoryForm.ProductName = product.ProductName;
            $scope.ProductQuanHistoryForm.Quantity = product.Quantity;
        }


        $scope.ShowProductQuanHistory = function (product) {
            $scope.SetProductQuanHistoryForm(product);
            $scope.ReloadGrid('ProductQuanHistory');
            $("#productQuanHisModal").modal();
        }

    }]);