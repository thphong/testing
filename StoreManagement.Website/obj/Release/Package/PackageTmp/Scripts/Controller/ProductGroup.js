$(document).ready(function () {
    $('#productGroupModal').on('show.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownProductGroupModal(true);
        });
    }).on('hide.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownProductGroupModal(false);
        });
    });
});

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
            if (tab == 'tab-list-product-group' || tab == 'tab-add-product-group') {
                $scope.IsShowParent = '0';
            }
            else {
                $scope.IsShowParent = '1';
            }

            if (tab != 'tab-list-product-group' && tab != 'tab-list-parent-group') {
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
            ParentId: "",
            Version: 0
        };

        $scope.ResetProductGroupForm = function () {
            $scope.ProductGroupForm.ProductGroupId = "-1";
            $scope.ProductGroupForm.GroupName = "";
            $scope.ProductGroupForm.IsActive = "1";
            $scope.ProductGroupForm.IsParent = "0";
            $scope.ProductGroupForm.ParentId = "";
            $scope.ProductGroupForm.Version = 0;
        };

        $scope.ProductGroupFormConfig = new ObjectDataConfig("T_Master_ProductGroups", $scope);
        $scope.ProductGroupFormConfig.CheckCanCreateObject();

        $scope.DeleteProductGroup = function (productGroup, isParent) {
            if (confirm("Bạn có muốn xóa '" + productGroup.GroupName + "'?")) {
                if ($scope.ProductGroupFormConfig.DeleteObject(productGroup.ProductGroupId)) {
                    if (!isParent) {
                        $scope.ReloadGrid('ProductGroups');
                        ShowSuccessMessage("Nhóm hàng được xóa thành công!");
                    }
                    else {
                        $scope.ReloadGrid('ProductParentGroups');
                        ShowSuccessMessage("Bộ danh mục xóa thành công!");
                    }
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

                $scope.ProductGroupFormConfig.CopyFields(productGroup, productGroup);

                $scope.ProductGroupFormConfig.SetObject(productGroup);

                if ($scope.ProductGroupFormConfig.SaveObject()) {
                    productGroup.IsEditing = false;
                    if ($scope.IsShowParent == '0') {
                        $scope.ReloadGrid('ProductGroups');
                        ShowSuccessMessage("Nhóm hàng hóa được lưu thành công!");
                    }
                    else {
                        ShowSuccessMessage("Bộ danh mục được lưu thành công!");
                    }
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
                        if ($scope.IsShowParent == '0') {
                            $scope.CurrentTabProductGroup = "tab-list-product-group";
                            ShowSuccessMessage("Nhóm hàng hóa được tạo thành công!");
                        }
                        else {
                            $scope.CurrentTabProductGroup = "tab-list-parent-group";
                            ShowSuccessMessage("Bộ danh mục được tạo thành công!");
                        }
                    }
                }
            }
        }

    }]);