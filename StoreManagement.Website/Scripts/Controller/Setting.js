function CheckLogInUnique(value) {
    if (value) {
        var config = new ObjectDataConfig("T_Master_User", null);
        var object = config.GetObject(value, 'LoginId');
        if (object) {
            return false;
        }
    }
    return true;
}

$(document).ready(function () {
    $('#rolesModal').on('show.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownUserRolesModal(true);
        });
    }).on('hide.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownUserRolesModal(false);
        });
    });
});

mdlCommon.controller('SettingController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.CurrentTab = "Customers";

        $scope.IsShownUserRolesModal = false;

        $scope.SetShownUserRolesModal = function (isShown) {
            $scope.IsShownUserRolesModal = isShown;
        }

        $scope.SetCurrentTab = function (tab) {
            if (tab != $scope.CurrentTab) {
                $scope.CurrentTab = tab;
            }
        }

        $scope.UserFormConfig = new ObjectDataConfig("T_Master_User", $scope);
        $scope.UserFormConfig.CheckCanCreateObject();
        $scope.UserStoreFormConfig = new ObjectDataConfig("T_Trans_User_Store", $scope);
        $scope.UserStoreFormConfig.CheckCanCreateObject();

        $scope.UserForm =
        {
            UserId: -1,
            LoginId: "",
            Password: "",
            UserName: "",
            Email: "",
            Phone: "",
            IsActive: 1
        }

        $scope.UserRoleForm =
        {
            StoreId: "",
            RoleId: "",
            UserId: ""
        }

        $scope.ResetUserForm = function () {
            $scope.UserForm.UserId = -1;
            $scope.UserForm.LoginId = "";
            $scope.UserForm.Password = "";
            $scope.UserForm.UserName = "";
            $scope.UserForm.Email = "";
            $scope.UserForm.Phone = "";
            $scope.UserForm.IsActive = 1;
        }

        $scope.ResetUserModal = function () {
            $scope.ResetUserForm();
            FValidation.ClearAllError();
        }

        $scope.SaveUser = function (user) {
            if (FValidation.CheckControls("check-user" + user.UserId)) {
                if (user.UserId == -1) {
                    user.Password = $.md5(user.LoginId + "12345");
                }
                $scope.UserFormConfig.SetObject(user);
                var userId = $scope.UserFormConfig.SaveObject();
                if (userId > 0) {
                    user.IsEditing = false;

                    if (user.UserId == -1) {
                        ShowSuccessMessage("Nhân viên được lưu thành công. Mật khẩu mặc định là " + user.LoginId + "12345.");
                        $("button[data-dismiss='modal']:visible").click();
                        $scope.ReloadGrid('Users');
                    }
                    else {
                        ShowSuccessMessage("Nhân viên được lưu thành công.");
                    }
                }
            }
        }

        $scope.RestorePassword = function (user) {
            if (confirm("Bạn có muốn lấy lại mật khẩu mặc định " + user.LoginId + "12345?")) {
                user.Password = $.md5(user.LoginId + "12345");
                $scope.UserFormConfig.SetObject(user);
                var userId = $scope.UserFormConfig.SaveObject();
                if (userId > 0) {
                    ShowSuccessMessage("Mật khẩu được khôi phục lại " + user.LoginId + "12345.");
                    user.IsEditing = false;
                }
            }
        }

        $scope.ViewUserRole = function (user) {
            $scope.UserFormConfig.CopyFields(user, $scope.UserForm);
            $scope.UserRoleForm.UserId = $scope.UserForm.UserId;
        }

        $scope.SaveUserRole = function ()
        {
            if (FValidation.CheckControls("")) {

                $scope.UserStoreFormConfig.SetObject($scope.UserRoleForm);
                if ($scope.UserStoreFormConfig.SaveObject() > 0) {
                    ShowSuccessMessage("Thêm nhóm người dùng thành công.");
                    $scope.ReloadGrid('UserRoles');
                    $scope.UserRoleForm.StoreId = "";
                    $scope.UserRoleForm.RoleId = "";
                }
            }
        }
    }]);