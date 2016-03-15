mdlCommon.controller('ProductGroupController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.CurrentTab = "tab-list";

        $scope.SetCurrentTab = function(tab)
        {
            $scope.CurrentTab = tab;
        }

        $scope.ProductGroupForm = {
            ProductGroupId: "-1",
            GroupName: "",
            IsActive: "1"
        };

        $scope.ResetProductGroupForm = function () {
            $scope.ProductGroupForm.ProductGroupId = "-1";
            $scope.ProductGroupForm.GroupName = "";
            $scope.ProductGroupForm.IsActive = "1"
        };

        $scope.ProductGroupFormConfig = new ObjectDataConfig("T_Master_ProductGroups");
                
        $scope.DeleteProductGroup = function (productGroup) {
            if (confirm("Bạn có muốn xóa nhóm hàng " + productGroup.GroupName + "?")) {
                if ($scope.ProductGroupFormConfig.DeleteObject(productGroup.ProductGroupId)) {
                    $scope.ReloadGrid('ProductGroups');
                    ShowSuccessMessage("Nhóm hàng được xóa thành công!");
                }
            }
        }

        $scope.EditProductGroup = function (productGroup) {
            productGroup.IsEditing = true;
            productGroup.BackupGroupName = productGroup.GroupName;
        }
        
        $scope.UndoProductGroup = function (productGroup) {
            productGroup.IsEditing = false;
            productGroup.GroupName = productGroup.BackupGroupName;
        }

        $scope.SaveProductGroup = function (productGroup) {
            if (FValidation.CheckControls("PG" + productGroup.ProductGroupId)) {
                $scope.ProductGroupFormConfig.SetObject(productGroup);
                if ($scope.ProductGroupFormConfig.SaveObject()) {
                    productGroup.IsEditing = false;
                    ShowSuccessMessage("Nhóm hàng hóa được lưu thành công!");
                }
            }
        }

        $scope.SaveProductGroupForm = function (isContinue) {
            if (FValidation.CheckControls("ProductGroup")) {
                $scope.ProductGroupFormConfig.SetObject($scope.ProductGroupForm);
                if ($scope.ProductGroupFormConfig.SaveObject()) {
                    ShowSuccessMessage("Nhóm hàng hóa được tạo thành công!");
                    $scope.ReloadGrid('ProductGroups');
                    $scope.ResetProductGroupForm();
                    if (!isContinue) {
                        $scope.CurrentTab = "tab-list";
                    }
                }
            }
        }

    }]);