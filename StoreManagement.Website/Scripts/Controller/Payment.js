$(document).ready(function () {
    $('input.datepicker').datepicker({ format: 'dd-mm-yyyy'/*, startDate: '23-03-2016'*/ });
});

mdlCommon.controller('InventoryController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.AdditionalFilter = {
            CostType: "1",
            StartDate: "",
            EndDate: "",
            Status: "0",
            PaymentType: "0"
        };

        $scope.CurrentTab = "Costs";

        $scope.SetCurrentTab = function (tab) {
            if (tab != $scope.CurrentTab) {
                $scope.CurrentTab = tab;
                $scope.ReloadGrid(tab);
            }
        }

        $scope.RangeDate = 0;
        $scope.SetRangeDate = function (option) {

            var curr = new Date(); // get current date
            var first = curr.getDate() - curr.getDay() + 1; // First day is the day of the month - the day of the week
            var last = first + 6; // last day is the first day + 6
            var y = curr.getFullYear(), m = curr.getMonth();
            var quarter = Math.floor(curr.getMonth() / 3);

            switch (option) {
                case 1: //This week
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(curr.setDate(first)));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(curr.setDate(last)));
                    break;
                case 2: //This month
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(y, m, 1));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(y, m + 1, 0));
                    break;
                case 3: //This quarter
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(y, quarter * 3, 1));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(y, quarter * 3 + 3, 0));
                    break;
                case 4: //last week
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(curr.setDate(first - 7)));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(curr.setDate(last - 7)));
                    break;
                case 5: //Last month
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(y, m - 1, 1));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(y, m, 0));
                    break;
                case 6: //Last quarter
                    $scope.AdditionalFilter.StartDate = formatDate(new Date(y, (quarter - 1) * 3, 1));
                    $scope.AdditionalFilter.EndDate = formatDate(new Date(y, quarter * 3, 0));
                    break;
            }
            $scope.RangeDate = option;
            $scope.ReloadGrid($scope.CurrentTab);
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

    }]);