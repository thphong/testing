mdlCommon.controller('UserController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.UserFormConfig = new ObjectDataConfig("T_Master_User", $scope);
        $scope.UserInfo = $scope.UserFormConfig.GetObject($scope.CurrentUser);
        $scope.UserForm =
        {
            UserId: -1,
            LoginId: "",
            UserName: "",
            Email: "",
            Phone: "",
            IsEditingPassword: false,
            OldPassword: "",
            NewPassword: "",
            NewPassword2: ""
        }
        $scope.UserFormConfig.CopyFields($scope.UserInfo, $scope.UserForm);

        $scope.UndoChangePassword = function () {
            $scope.UserForm.IsEditingPassword = false;
            $scope.UserForm.OldPassword = "";
            $scope.UserForm.NewPassword = "";
            $scope.UserForm.NewPassword2 = "";
        }


        $scope.ChangePassword = function () {
            if (FValidation.CheckControls("")) {
                var oldPassword = $.md5($scope.UserForm.OldPassword);
                if (oldPassword != $scope.UserInfo.Password || $scope.UserForm.NewPassword != $scope.UserForm.NewPassword2) {
                    ShowErrorMessage("Mật khẩu cũ không đúng hoặc mật khẩu mới không khớp nhau.");
                }
                else {

                    var newPassword = $.md5($scope.UserForm.NewPassword);
                    $scope.UserInfo.Password = newPassword;

                    $scope.UserFormConfig.SetObject($scope.UserInfo);
                    var userId = $scope.UserFormConfig.SaveObject();
                    if (userId > 0) {
                        ShowSuccessMessage("Mật khẩu được đổi thành công.");
                        $scope.UndoChangePassword();
                    }
                }
            }
        }

    }]);