﻿$(document).ready(function () {
    $('#attributeModal').on('show.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownAttributeModal(true);
        });
    }).on('hide.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownAttributeModal(false);
        });
    });
});

mdlCommon.controller('AttributeController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        //$controller('ctrlPaging', { $scope: $scope });

        $scope.CurrentTabAttribute = "tab-list";
        $scope.IsShownAttributeModal = false;

        $scope.SetShownAttributeModal = function (isShown) {
            $scope.IsShownAttributeModal = isShown;
        }

        $scope.SetCurrentTabAttribute = function (tab) {
            $scope.CurrentTabAttribute = tab;
        }

        $scope.AttributeForm = {
            AttributeId: "-1",
            AttributeName: "",
            IsActive: "1"
        };

        $scope.ResetAttributeForm = function () {
            $scope.AttributeForm.AttributeId = "-1";
            $scope.AttributeForm.AttributeName = "";
            $scope.AttributeForm.IsActive = "1"
        };

        $scope.AttributeFormConfig = new ObjectDataConfig("T_Master_Attibutes");

        $scope.DeleteAttribute = function (attribute) {
            if (confirm("Bạn có muốn xóa thuộc tính " + attribute.AttributeName + "?")) {
                if ($scope.AttributeFormConfig.DeleteObject(attribute.AttributeId)) {
                    $scope.ReloadGrid('Attributes');
                    ShowSuccessMessage("Thuộc tính được xóa thành công!");
                }
            }
        }

        $scope.EditAttribute = function (attribute) {
            attribute.IsEditing = true;
            attribute.BackupAttributeName = attribute.AttributeName;
        }

        $scope.UndoAttribute = function (attribute) {
            attribute.IsEditing = false;
            attribute.AttributeName = attribute.BackupAttributeName;
        }

        $scope.SaveAttribute = function (attribute) {
            if (FValidation.CheckControls("AT" + attribute.AttributeId)) {
                $scope.AttributeFormConfig.SetObject(attribute);
                if ($scope.AttributeFormConfig.SaveObject()) {
                    attribute.IsEditing = false;
                    ShowSuccessMessage("Thuộc tính được lưu thành công!");
                }
            }
        }

        $scope.SaveAttributeForm = function (isContinue) {
            if (FValidation.CheckControls("Attribute")) {
                $scope.AttributeFormConfig.SetObject($scope.AttributeForm);
                if ($scope.AttributeFormConfig.SaveObject()) {
                    ShowSuccessMessage("Thuộc tính được tạo thành công!");
                    $scope.ReloadGrid('Attributes');
                    $scope.ResetAttributeForm();
                    if (!isContinue) {
                        $scope.CurrentTabAttribute = "tab-list";
                    }
                }
            }
        }

    }]);