$(document).ready(function () {
    $('#costTypeModal').on('show.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownCostTypeModal(true);
        });
    }).on('hide.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownCostTypeModal(false);
        });
    });
});

mdlCommon.controller('CostTypeController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        //$controller('ctrlPaging', { $scope: $scope });

        $scope.CurrentTabCostType = "tab-list";
        $scope.IsShownCostTypeModal = false;

        $scope.SetShownCostTypeModal = function (isShown) {
            $scope.IsShownCostTypeModal = isShown;
        }

        $scope.SetCurrentTabCostType = function (tab) {
            $scope.CurrentTabCostType = tab;
        }

        $scope.CostTypeForm = {
            CostTypeId: "-1",
            CostTypeName: "",
            Notes: "",
            IsActive: "1"
        };

        $scope.ResetCostTypeForm = function () {
            $scope.CostTypeForm.CostTypeId = "-1";
            $scope.CostTypeForm.CostTypeName = "";
            $scope.CostTypeForm.Notes = "";
            $scope.CostTypeForm.IsActive = "1"
        };

        $scope.CostTypeFormConfig = new ObjectDataConfig("T_Master_CostTypes", $scope);

        $scope.DeleteCostType = function (costType) {
            if (confirm("Bạn có muốn xóa loại chi phí " + costType.CostTypeName + "?")) {
                if ($scope.CostTypeFormConfig.DeleteObject(costType.CostTypeId)) {
                    $scope.ReloadGrid('CostTypes');
                    ShowSuccessMessage("Loại chi phí được xóa thành công!");
                }
            }
        }

        $scope.EditCostType = function (costType) {
            costType.IsEditing = true;
            costType.BackupCostTypeName = costType.CostTypeName;
        }

        $scope.UndoCostType = function (costType) {
            costType.IsEditing = false;
            costType.CostTypeName = costType.BackupCostTypeName;
        }

        $scope.SaveCostType = function (costType) {
            if (FValidation.CheckControls("CT" + costType.CostTypeId)) {
                $scope.CostTypeFormConfig.SetObject(costType);
                if ($scope.CostTypeFormConfig.SaveObject()) {
                    costType.IsEditing = false;
                    ShowSuccessMessage("Loại chi phí được lưu thành công!");
                }
            }
        }

        $scope.SaveCostTypeForm = function (isContinue) {
            if (FValidation.CheckControls("CostType")) {
                $scope.CostTypeFormConfig.SetObject($scope.CostTypeForm);
                if ($scope.CostTypeFormConfig.SaveObject()) {
                    ShowSuccessMessage("Loại chi phí được tạo thành công!");
                    //$scope.ReloadGrid('CostTypes');
                    $scope.ResetCostTypeForm();
                    if (!isContinue) {
                        $scope.CurrentTabCostType = "tab-list";
                    }
                }
            }
        }

    }]);