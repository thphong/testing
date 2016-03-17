mdlCommon.controller('ProductGroupController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.CurrentTab = "tab-list-product-group";

        $scope.SetCurrentTab = function (tab) {
            $scope.CurrentTab = tab;
            if (tab == 'tab-list-product-group' || tab == 'tab-add-product-group') {
                $scope.IsShowParent = '0';
            }
            else {
                $scope.IsShowParent = '1';
            }

            if (tab == 'tab-list-product-group' || tab == 'tab-list-parent-group') {
                $scope.ReloadGrid('ProductGroups');
            }
            else {
                FValidation.ClearAllError();
                $scope.ResetProductGroupForm();
            }


            $scope.ProductGroupForm.IsParent = $scope.IsShowParent;
        }

        $scope.IsShowParent = '0';

        $scope.ProductGroupForm = {
            ProductGroupId: "-1",
            GroupName: "",
            IsActive: "1",
            IsParent: "0",
            ParentId: ""
        };

        $scope.ResetProductGroupForm = function () {
            $scope.ProductGroupForm.ProductGroupId = "-1";
            $scope.ProductGroupForm.GroupName = "";
            $scope.ProductGroupForm.IsActive = "1";
            $scope.ProductGroupForm.IsParent = "0";
            $scope.ProductGroupForm.ParentId = "";
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
            productGroup.ParentId = String(productGroup.ParentId);
            productGroup.IsEditing = true;
            productGroup.BackupGroupName = productGroup.GroupName;
        }

        $scope.UndoProductGroup = function (productGroup) {
            productGroup.IsEditing = false;
            productGroup.GroupName = productGroup.BackupGroupName;
        }

        $scope.SaveProductGroup = function (productGroup) {
            if (FValidation.CheckControls("PG" + productGroup.ProductGroupId)) {

                $scope.ProductGroupFormConfig.ConvertFieldsToString(productGroup, productGroup);

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
                    ShowSuccessMessage("Nhóm hàng hóa được tạo thành công!");
                    $scope.ReloadGrid('ProductGroups');
                    $scope.ResetProductGroupForm();
                    if (!isContinue) {
                        if ($scope.IsShowParent == '0') {
                            $scope.CurrentTab = "tab-list-product-group";
                        }
                        else {
                            $scope.CurrentTab = "tab-list-parent-group";
                        }
                    }
                }
            }
        }

    }]);