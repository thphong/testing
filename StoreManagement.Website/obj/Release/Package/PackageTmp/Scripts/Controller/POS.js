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

    $('#annoucementPOSModal').on('show.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownPOSAnnoucement(true);
        });
    }).on('hide.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownPOSAnnoucement(false);
        });
    });

    $("#OrderController").keydown(function (event) {
        var controllerId = $(this).attr("id");
        var scope = angular.element(document.getElementById(controllerId)).scope();
        if (scope.OrderForm.IsPOS) {
            if (event.which == 113) { //F2
                scope.$apply(function () {
                    scope.SavePOSOrder();
                });
                return false;
            }
            else if (event.which == 114) { //F3
                scope.$apply(function () {
                    scope.SavePrintPOSOrder();
                });
                return false;
            }
        }
    });

});


mdlCommon.controller('POSController',
['$scope', '$filter', '$controller', '$interpolate', '$sce',
    function ($scope, $filter, $controller, $interpolate, $sce) {

        $scope.SortByCreatedDate = function () {
            $scope.Config.Products.GridSortCondition = "ProductId.CreatedDate DESC";
            $scope.ReloadGrid("Products");

        }

        $scope.SortByNumSelling = function () {
            $scope.Config.Products.GridSortCondition = "[NumSelling] DESC";
            $scope.ReloadGrid("Products");
        }

        $scope.IsShowingPOSCustomer = true;
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
                $scope.CancelOrder();
                $scope.ReloadGrid('Products');
            }
        }

        $scope.SavePrintPOSOrder = function () {
            $scope.SaveOrderForm(2);

            if ($scope.OrderForm.OrderId > 0) {
                $scope.GetListPrintTerm("Order");
                $scope.GetPrintTemplate("ORDER_POS");

                setTimeout(function () {
                    $scope.PrintData("divPrint");
                    $scope.$apply(function () {
                        $scope.CancelOrder();
                        $scope.ReloadGrid('Products');
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

        $scope.SetShownPOSAnnoucement = function (isShown) {
            $scope.IsShownPOSAnnoucement = isShown;
        }

        $scope.configPromotion = new GridViewConfig("");
        $scope.configPromotion.GridDataAction = "getall";
        $scope.configPromotion.GridDataType = "function";
        $scope.configPromotion.GridDataObject = "dbo.UFN_Promotion_Calcualte";
        $scope.configPromotion.GridParametersExpression = "{{OrderForm.Customer}}, {{CurrentStore}}";
        $scope.ListPromotion = [];
        
        //Calculate Promotion
        $scope.$watch('OrderForm.Customer', function (newVal, oldVal) {
            if (newVal > 0 && $scope.OrderForm.IsPOS) {

                $scope.configPromotion.EvaluateFieldExpression($interpolate, $scope);
                $scope.ListPromotion = $scope.configPromotion.GetListData();

                $scope.CalCulatePromotion();
            }
        }, false);

        $scope.CalCulatePromotion = function()
        {
            if ($scope.ListPromotion.length > 0)
            {
                for (var i = 0; i < $scope.ListPromotion.length ; i++) {
                    var promotion = $scope.ListPromotion[i];
                    if ($scope.OrderForm.Price >= promotion.MinConditionAmount) {
                        if (promotion.IsPercent == 1) {
                            $scope.OrderForm.Discount = $scope.OrderForm.Price * promotion.Amount / 100;
                        }
                        else {
                            $scope.OrderForm.Discount = promotion.Amount;
                        }
                        if ($scope.OrderForm.Discount > promotion.MaxAmount) {
                            $scope.OrderForm.Discount = promotion.MaxAmount;
                        }
                        $scope.DiscountForm.PromotionName = promotion.PromoteName;
                        break;
                    }
                }

                if ($scope.OrderForm.Discount > $scope.OrderForm.Price) {
                    $scope.OrderForm.Discount = $scope.OrderForm.Price;
                }

                $scope.OrderForm.IsDiscountPercent = 0;

                $scope.Summarize();
            }

        }

        //Annoucement
        $scope.Announcement =
        {
            Title: "",
            Body: "",
            CreatorName: "",
            CreatedDate: "",
            IsShow: false
        }

        $scope.ShowAnnouncement = function (announce)
        {
            $scope.Announcement.Title = announce.Title;
            $scope.Announcement.Body = $sce.trustAsHtml(announce.Body);
            $scope.Announcement.CreatorName = announce.CreatorName;
            $scope.Announcement.CreatedDate = announce.CreatedDate;
            $scope.Announcement.IsShow = true;
        }
    }]);