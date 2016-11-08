mdlCommon.controller('ProductGroupController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        //$controller('ctrlPaging', { $scope: $scope });

        $scope.CurrentTabProductGroup = "tab-list-product-group";
        $scope.IsShownProductGroupModal = false;

        $scope.SetShownProductGroupModal = function (isShown) {
            $scope.IsShownProductGroupModal = isShown;
        }

        $scope.SetCurrentTabProductGroup = function (tab) {
            $scope.CurrentTabProductGroup = tab;

            if (tab != 'tab-list-product-group' && tab != 'tab-list-parent-group') {
                FValidation.ClearAllError();
                $scope.ResetProductGroupForm();
            }
        }

        $scope.ProductGroupForm = {
            ProductGroupId: "-1",
            GroupName: "",
            IsActive: "1",
            Version: 0,
            StoreId: $scope.ParentStore
        };

        $scope.ResetProductGroupForm = function () {
            $scope.ProductGroupForm.ProductGroupId = "-1";
            $scope.ProductGroupForm.GroupName = "";
            $scope.ProductGroupForm.IsActive = "1";
            $scope.ProductGroupForm.Version = 0;
            $scope.ProductGroupForm.StoreId = $scope.ParentStore;
        };

        $scope.ProductGroupFormConfig = new ObjectDataConfig("T_Master_ProductGroups", $scope);
        $scope.ProductGroupFormConfig.CheckCanCreateObject();

        $scope.DeleteProductGroup = function (productGroup) {
            if (confirm("Bạn có muốn xóa '" + productGroup.GroupName + "'?")) {
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

                $scope.ProductGroupFormConfig.CopyFields(productGroup, productGroup);

                $scope.ProductGroupFormConfig.SetObject(productGroup);

                if ($scope.ProductGroupFormConfig.SaveObject()) {
                    productGroup.IsEditing = false;
                    $scope.ReloadGrid('ProductGroups');
                    ShowSuccessMessage("Nhóm hàng hóa được lưu thành công!");
                }
            }
        }

        $scope.SaveProductGroupForm = function (isContinue) {
            if (FValidation.CheckControls("ProductGroup")) {
                $scope.ProductGroupFormConfig.SetObject($scope.ProductGroupForm);
                if ($scope.ProductGroupFormConfig.SaveObject()) {
                    //$scope.ReloadGrid('ProductGroups');
                    $scope.ResetProductGroupForm();
                    if (!isContinue) {
                        $scope.CurrentTabProductGroup = "tab-list-product-group";
                    }
                    ShowSuccessMessage("Nhóm hàng hóa được tạo thành công!");
                }
            }
        }

    }]);