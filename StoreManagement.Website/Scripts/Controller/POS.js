
$(document).ready(function () {
    $('#reportPOSModal').on('show.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownPOSReport(true);
        });
    }).on('hide.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownPOSReport(false);
        });
    });

    $('#inventoryPOSModal').on('show.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownPOSInventory(true);
        });
    }).on('hide.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownPOSInventory(false);
        });
    });
});

mdlCommon.controller('POSController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {

        $scope.SortByCreatedDate = function () {
            $scope.Config.Products.GridSortCondition = "ProductId.CreatedDate DESC";
            $scope.ReloadGrid("Products");

        }

        $scope.SortByNumSelling = function () {
            $scope.Config.Products.GridSortCondition = "[NumSelling] DESC";
            $scope.ReloadGrid("Products");
        }

        $scope.IsShowingPOSCustomer = false;
        $scope.IsShowingPOSSummary = true;
        $scope.CurrentDate = new Date();
        $scope.AdditionalPOSFilter = {
            InventoryProductGroup: "0",
            InventoryProductType: "0"
        };

        //Form
        $scope.CancelOrder = function () {
            $scope.ResetOrderForm();
            $scope.ListProductsOrder.splice(0, $scope.ListProductsOrder.length);
        }

        $scope.SavePOSOrder = function () {
            $scope.SaveOrderForm(2);

            if ($scope.OrderForm.OrderId > 0) {
                $scope.GetListPrintTerm("Order");
                $scope.GetPrintTemplate("ORDER_POS");

                setTimeout(function () {
                    $scope.PrintData("divPrint");
                    $scope.$apply(function () {
                        $scope.CancelOrder();
                    });
                }, 100);
            }
        }

        //POS Report
        $scope.SelectedOrderId = -1;

        $scope.SelectOrderId = function (order) {
            if ($scope.SelectedOrderId == order.OrderId) {
                $scope.SelectedOrderId = -1;
            }
            else {
                $scope.SelectedOrderId = order.OrderId;
            }
        }

        $scope.SetShownPOSReport = function (isShown) {
            $scope.IsShownPOSReport = isShown;
        }

        $scope.SetShownPOSInventory = function (isShown) {
            $scope.IsShownPOSInventory = isShown;
        }
    }]);