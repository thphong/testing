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

mdlCommon.controller('SettingController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.CurrentTab = "Customers";

        $scope.SetCurrentTab = function (tab) {
            if (tab != $scope.CurrentTab) {
                $scope.CurrentTab = tab;
            }
        }

        $scope.UserFormConfig = new ObjectDataConfig("T_Master_User", $scope);
        $scope.UserFormConfig.CheckCanCreateObject();

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
                user.Password = $.md5(user.LoginId + "12345");
                $scope.UserFormConfig.SetObject(user);
                var userId = $scope.UserFormConfig.SaveObject();
                if (userId > 0) {
                    ShowSuccessMessage("Nhân viên được lưu thành công. Mật khẩu mặc định là " + user.LoginId + "12345.");
                    user.IsEditing = false;

                    if (user.UserId == -1) {
                        $("button[data-dismiss='modal']:visible").click();
                        $scope.ReloadGrid('Users');
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

    }]);