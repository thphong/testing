$(document).ready(function () {
    $('input.datepicker').datepicker({ format: 'dd-mm-yyyy'/*, startDate: '23-03-2016'*/ });
});

mdlCommon.controller('InventoryController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('CostTypeController', { $scope: $scope });

        $scope.AdditionalFilter = {
            CostType: "1",
            Status: "0",
            PaymentType: "0"
        };

        $scope.CurrentTab = "Costs";

        $scope.SetCurrentTab = function (tab) {
            if (tab != $scope.CurrentTab) {
                $scope.CurrentTab = tab;
                //$scope.ReloadGrid(tab);
            }
        }

        $scope.CostFormConfig = new ObjectDataConfig("T_Trans_Cost");
        $scope.PaymentFormConfig = new ObjectDataConfig("T_Trans_Payment");

        $scope.DeleteCost = function (cost)
        {
            if (confirm("Bạn có muốn xóa phiếu chi phí " + cost.CostCode + "?")) {
                if ($scope.CostFormConfig.DeleteObject(cost.CostId)) {
                    $scope.ReloadGrid('Costs');
                    ShowSuccessMessage("Phiếu chi phí được xóa thành công!");
                }
            }
        }

        $scope.DeletePayment = function (payment) {
            if (confirm("Bạn có muốn xóa phiếu thu cho đơn hàng " + payment.OrderCode + " ?")) {
                if ($scope.PaymentFormConfig.DeleteObject(payment.PaymentId)) {
                    $scope.ReloadGrid('Payments');
                    ShowSuccessMessage("Phiếu thu được xóa thành công!");
                }
            }
        }

        $scope.CostForm = {
            CostName: "",
            CostTypeId: "",
            PaidDate: formatDate(new Date()),
            Amount: "",
            Notes: "",
            IsActive: 1
        };

        $scope.ResetCostForm = function() {
            $scope.CostForm.CostName = "";
            $scope.CostForm.CostTypeId = "";
            $scope.CostForm.PaidDate = formatDate(new Date());
            $scope.CostForm.Amount = "";
            $scope.CostForm.Notes = "";
            $scope.CostForm.IsActive = 1;
        };

        $scope.AddCost = function()
        {
            FValidation.ClearAllError();
            $scope.ResetCostForm();
        }

        $scope.SaveCostForm = function () {
            if (FValidation.CheckControls("check-cost")) {
                $scope.CostFormConfig.SetObject($scope.CostForm);
                if ($scope.CostFormConfig.SaveObject()) {
                    ShowSuccessMessage("Phiếu chi phí được lưu thành công!");
                    $scope.ReloadGrid('Costs');
                    $("button[data-dismiss='modal']:visible").click();
                }
            }
        }

    }]);