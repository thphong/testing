mdlCommon.controller('PaymentController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('CostTypeController', { $scope: $scope });
        $controller('PrintController', { $scope: $scope });

        $scope.AdditionalFilter = {
            CostType: "1",
            Status: "0",
            PaymentType: "0"
        };

        $scope.CurrentTab = "Costs";
        $scope.SelectedCashier;
        $scope.IsShownReceiveHistoryModal = false;

        $scope.SetShownReceiveHistoryModal = function (isShown) {
            $scope.IsShownReceiveHistoryModal = isShown;
        }
        $scope.SetCurrentTab = function (tab) {
            if (tab != $scope.CurrentTab) {
                $scope.CurrentTab = tab;
            }
        }

        $scope.CostFormConfig = new ObjectDataConfig("T_Trans_Cost", $scope);
        $scope.PaymentFormConfig = new ObjectDataConfig("T_Trans_Payment", $scope);
        $scope.ReceivementConfig = new ObjectDataConfig("T_Trans_Receivement", $scope);

        $scope.CostFormConfig.CheckCanCreateObject();
        $scope.ReceivementConfig.CheckCanCreateObject();

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
            CostCode: "",
            CostTypeId: "",
            CostTypeName: "",
            PaidDate: formatDate(new Date()),
            PaidBy: $scope.CurrentUser,
            PayerName: "",
            Amount: "",
            Notes: "",
            StoreId: $scope.CurrentStore,
            IsActive: 1,
            Version : 0
        };

        $scope.ResetCostForm = function() {
            $scope.CostForm.CostName = "";
            $scope.CostForm.CostCode = "";
            $scope.CostForm.PayerName = "";
            $scope.CostForm.CostTypeId = "";
            $scope.CostForm.CostTypeName = "";
            $scope.CostForm.PaidBy = $scope.CurrentUser;
            $scope.CostForm.PaidDate = formatDate(new Date());
            $scope.CostForm.Amount = "";
            $scope.CostForm.Notes = "";
            $scope.CostForm.IsActive = 1;
            $scope.CostForm.StoreId = $scope.CurrentStore;
            $scope.CostForm.Version = 0;
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

                //get value to print
                $scope.CostForm.CostTypeName = $("select[ng-model='CostForm.CostTypeId'] option:selected").html();
                $scope.CostForm.PayerName = $scope.CurrentUserName;
            }
        }

        $scope.PrintCost = function (cost) {

            $scope.CostFormConfig.CopyFields(cost, $scope.CostForm);

            //print
            $scope.PrintForm();

        }

        $scope.PrintForm = function () {
            $scope.GetListPrintTerm("Cost");
            $scope.GetPrintTemplate("COST");

            setTimeout(function () {
                $scope.PrintData("divPrint");
            }, 100);
        }

        $scope.Receivement = function (receive) {
            if (FValidation.CheckControls("receive" + receive.Cashier)) {
                receive.IsReceive = 1;
                $scope.ReceivementConfig.SetObject(receive);
                if ($scope.ReceivementConfig.SaveObject() > 0) {
                    ShowSuccessMessage("Đã lưu phiếu nhận tiền thành công!");
                    $scope.ReloadGrid('CollectMoneys');
                }
            }
        }

        $scope.Givement = function (give) {
            if (FValidation.CheckControls("give" + give.Cashier)) {
                give.IsReceive = 0;
                $scope.ReceivementConfig.SetObject(give);
                if ($scope.ReceivementConfig.SaveObject() > 0) {
                    ShowSuccessMessage("Đã lưu phiếu ứng tiền thành công!");
                    $scope.ReloadGrid('CollectMoneys');
                }
            }
        }

        $scope.ShowReceiveHistory = function (receive) {
            $scope.SelectedCashier = receive;
            $scope.SetShownReceiveHistoryModal(true);
            $("#receiveHistoryModal").modal('show');
        }



    }]);