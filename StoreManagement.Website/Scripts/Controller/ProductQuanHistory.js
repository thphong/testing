
mdlCommon.controller('ProductQuanHistoryController',
['$scope', '$filter', '$interpolate', '$controller',
    function ($scope, $filter, $interpolate, $controller) {

        $scope.ProductQuanHistoryForm = {
            ProductId: "-1",
            ProductCode: "",
            ProductName: "",
            Quantity: "0"
        };


        $scope.ConfigStoreList = new GridViewConfig("");
        $scope.ConfigStoreList.GridDataAction = "getall";
        $scope.ConfigStoreList.GridDataType = "table";
        $scope.ConfigStoreList.GridDataObject = "T_Trans_Product_Store";
        $scope.ConfigStoreList.GridDefinedColums = "StoreId;StoreId.StoreCode;Quantity";
        $scope.ConfigStoreList.GridFilterConditionExpression = "[ProductId] = {{ProductQuanHistoryForm.ProductId}}";
        $scope.ConfigStoreList.GridSortCondition = "StoreId.StoreCode ASC";

        $scope.ListStores = [];
        $scope.SelectedStoreId = "";

        $scope.SetProductQuanHistoryForm = function (product) {
            $scope.ProductQuanHistoryForm.ProductId = product.ProductId;
            $scope.ProductQuanHistoryForm.ProductCode = product.ProductCode;
            $scope.ProductQuanHistoryForm.ProductName = product.ProductName;
            $scope.ProductQuanHistoryForm.Quantity = product.Quantity;
        }

        $scope.ShowProductQuanHistory = function (product) {
            $scope.SetProductQuanHistoryForm(product);

            $scope.ConfigStoreList.GridFilterCondition = $interpolate($scope.ConfigStoreList.GridFilterConditionExpression)($scope);
            $scope.ListStores = $scope.ConfigStoreList.GetListData();
            if ($scope.ListStores.length > 0) {
                $scope.SelectedStoreId = $scope.ListStores[0].StoreId;
            }

            $scope.ReloadGrid('ProductQuanHistory');

            $("#productQuanHisModal").modal();
        }

        $scope.SelectStore = function (store) {
            $scope.SelectedStoreId = store.StoreId;
            $scope.ReloadGrid('ProductQuanHistory');
        }

    }]);