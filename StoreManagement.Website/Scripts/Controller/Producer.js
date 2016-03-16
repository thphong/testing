﻿mdlCommon.controller('ProducerController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.CurrentTab = "tab-list";

        $scope.SetCurrentTab = function (tab) {
            $scope.CurrentTab = tab;
        }

        $scope.ProducerForm = {
            ProducerId: "-1",
            ProducerName: "",
            IsActive: "1"
        };

        $scope.ResetProducerForm = function () {
            $scope.ProducerForm.ProducerId = "-1";
            $scope.ProducerForm.ProducerName = "";
            $scope.ProducerForm.IsActive = "1"
        };

        $scope.ProducerFormConfig = new ObjectDataConfig("T_Master_Producers");

        $scope.DeleteProducer = function (producer) {
            if (confirm("Bạn có muốn xóa nhà sản xuất " + producer.ProducerName + "?")) {
                if ($scope.ProducerFormConfig.DeleteObject(producer.ProducerId)) {
                    $scope.ReloadGrid('Producers');
                    ShowSuccessMessage("Nhà sản xuất được xóa thành công!");
                }
            }
        }

        $scope.EditProducer = function (producer) {
            producer.IsEditing = true;
            producer.BackupProducerName = producer.ProducerName;
        }

        $scope.UndoProducer = function (producer) {
            producer.IsEditing = false;
            producer.ProducerName = producer.BackupProducerName;
        }

        $scope.SaveProducer = function (producer) {
            if (FValidation.CheckControls("PC" + producer.ProducerId)) {
                $scope.ProducerFormConfig.SetObject(producer);
                if ($scope.ProducerFormConfig.SaveObject()) {
                    producer.IsEditing = false;
                    ShowSuccessMessage("Nhà sản xuất được lưu thành công!");
                }
            }
        }

        $scope.SaveProducerForm = function (isContinue) {
            if (FValidation.CheckControls("Producer")) {
                $scope.ProducerFormConfig.SetObject($scope.ProducerForm);
                if ($scope.ProducerFormConfig.SaveObject()) {
                    ShowSuccessMessage("Nhà sản xuất được tạo thành công!");
                    $scope.ReloadGrid('Producers');
                    $scope.ResetProducerForm();
                    if (!isContinue) {
                        $scope.CurrentTab = "tab-list";
                    }
                }
            }
        }

    }]);