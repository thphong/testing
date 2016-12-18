mdlCommon.controller('ProductQuanHistoryController',
['$scope', '$filter', '$interpolate', '$controller',
    function ($scope, $filter, $interpolate, $controller) {

        $scope.IsShownProductQuanHistoryModal = false;

        $scope.SetShownProductQuanHistoryModal = function (isShown) {
            $scope.IsShownProductQuanHistoryModal = isShown;
        }

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
        $scope.ConfigStoreList.GridFilterConditionExpression = "ProductId = {{ProductQuanHistoryForm.ProductId}}";
        $scope.ConfigStoreList.GridSortCondition = "StoreId.StoreCode ASC";

        $scope.ListStores = [];
        $scope.SelectedStoreId = $scope.CurrentStore;

        $scope.SetProductQuanHistoryForm = function (product) {
            $scope.ProductQuanHistoryForm.ProductId = product.ProductId;
            $scope.ProductQuanHistoryForm.ProductCode = product.ProductCode;
            $scope.ProductQuanHistoryForm.ProductName = product.ProductName;
        }

        $scope.ShowProductQuanHistory = function (product) {
            $scope.SetShownProductQuanHistoryModal(true);
            $scope.SetProductQuanHistoryForm(product);

            $scope.ConfigStoreList.GridFilterCondition = $interpolate($scope.ConfigStoreList.GridFilterConditionExpression)($scope);
            $scope.ListStores = $scope.ConfigStoreList.GetListData();
            
            var quantity = 0;
            for (var i = 0 ; i < $scope.ListStores.length; i++)
            {
                quantity += $scope.ListStores[i].Quantity;
            }

            $scope.ProductQuanHistoryForm.Quantity = quantity;

            //$scope.ReloadGrid('ProductQuanHistory');
            $("#productQuanHisModal").modal('show');
        }

        $scope.ShowCountProductQuanHistory = function (product, divId) {
            setTimeout(function () {
                $scope.SetProductQuanHistoryForm(product);
                $scope.ConfigStoreList.GridFilterCondition = $interpolate($scope.ConfigStoreList.GridFilterConditionExpression)($scope);
                $scope.ListStores = $scope.ConfigStoreList.GetListData();

                var quantity = 0;
                for (var i = 0 ; i < $scope.ListStores.length; i++) {
                    quantity += $scope.ListStores[i].Quantity;
                }
                $("#" + divId).html("(" + quantity + ")");
            }, 10);
        }

        $scope.SelectStore = function (store) {
            $scope.SelectedStoreId = store.StoreId;
            $scope.ReloadGrid('ProductQuanHistory');
        }

    }]);