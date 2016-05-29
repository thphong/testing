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


    $('#PrintTermModal').on('show.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownTemplateTermsModal(true);
        });
    }).on('hide.bs.modal', function (e) {
        var modalId = $(this).attr("id");
        var scope = angular.element(document.getElementById(modalId)).scope();
        scope.$apply(function () {
            scope.SetShownTemplateTermsModal(false);
        });
    });


});

mdlCommon.controller('SettingController',
['$scope', '$filter', '$controller', '$sce',
    function ($scope, $filter, $controller, $sce) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('ProductGroupController', { $scope: $scope });
        $controller('PrintController', { $scope: $scope });

        $scope.CurrentTab = "Users";

        $scope.IsShownUserRolesModal = false;
        $scope.IsShownTemplateTermsModal = false;

        $scope.SetShownUserRolesModal = function (isShown) {
            $scope.IsShownUserRolesModal = isShown;
        }

        $scope.SetShownTemplateTermsModal = function (isShown) {
            $scope.IsShownTemplateTermsModal = isShown;
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
            UserId: "",
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

        $scope.CheckUserRoleUnique = function () {
            var list = $scope.DataSet.UserRoles.Data;
            for (var i = 0 ; i < list.length; i++) {
                if (list[i].StoreId == $scope.UserRoleForm.StoreId && list[i].RoleId == $scope.UserRoleForm.RoleId) {
                    return false;
                }
            }
            return true;
        }

        $scope.SaveUserRole = function () {
            if (FValidation.CheckControls("")) {
                if ($scope.CheckUserRoleUnique()) {
                    $scope.UserStoreFormConfig.SetObject($scope.UserRoleForm);
                    if ($scope.UserStoreFormConfig.SaveObject() > 0) {
                        ShowSuccessMessage("Thêm chức vụ của nhân viên thành công.");
                        $scope.ReloadGrid('UserRoles');
                        $scope.UserRoleForm.StoreId = "";
                        $scope.UserRoleForm.RoleId = "";
                    }
                }
                else {
                    ShowErrorMessage("Nhân viên đã có chức vụ này ở cửa hàng đang chọn.");
                }
            }
        }

        $scope.DeleteUserRole = function (userRole) {
            if (confirm("Bạn có muốn xóa chức vụ của nhân viên?")) {
                if ($scope.UserStoreFormConfig.HardDeleteObject(userRole.Id)) {
                    ShowSuccessMessage("Chức vụ của nhân viên được xóa thành công.");
                    $scope.ReloadGrid('UserRoles');
                }
            }
        }

        $scope.StoreForm =
        {
            StoreId: -1,
            StoreCode: "",
            StoreName: "",
            PresenterName: "",
            PhoneNumber: "",
            Address: "",
            TaxCode: "",
            ProductGroup: "",
            IsEditing: false,
            Version: 0
        }

        $scope.ResetStoreForm = function () {
            $scope.StoreForm.StoreId = -1;
            $scope.StoreForm.StoreCode = "";
            $scope.StoreForm.StoreName = "";
            $scope.StoreForm.PresenterName = "";
            $scope.StoreForm.PhoneNumber = "";
            $scope.StoreForm.Address = "";
            $scope.StoreForm.TaxCode = "";
            $scope.StoreForm.ProductGroup = "";
            $scope.StoreForm.IsEditing = false;
            $scope.StoreForm.Version = 0;
        }

        $scope.StoreFormConfig = new ObjectDataConfig("T_Master_Stores", $scope);
        $scope.StoreFormConfig.CheckCanCreateObject();
        $scope.LoadStoreForm = function () {
            if ($scope.StoreForm.StoreId <= 0) {
                var store = $scope.StoreFormConfig.GetObject($scope.CurrentStore);
                $scope.StoreFormConfig.CopyFields(store, $scope.StoreForm);
            }
        }

        $scope.UndoStoreForm = function () {
            $scope.StoreForm.IsEditing = false;
            var store = $scope.StoreFormConfig.GetObject($scope.CurrentStore);
            $scope.StoreFormConfig.CopyFields(store, $scope.StoreForm);
            FValidation.ClearAllError();
        }

        $scope.SaveStoreForm = function () {
            if (FValidation.CheckControls("")) {
                $scope.StoreFormConfig.SetObject($scope.StoreForm);
                var storeId = $scope.StoreFormConfig.SaveObject();
                if (storeId > 0) {
                    ShowSuccessMessage("Cửa hàng được đổi thành công.");
                    $scope.ReloadGrid('Stores');
                    if ($scope.StoreForm.StoreId == -1) {
                        var store = $scope.StoreFormConfig.GetObject($scope.CurrentStore);
                        $scope.StoreFormConfig.CopyFields(store, $scope.StoreForm);
                    }
                    $scope.StoreForm.IsEditing = false;
                }
            }
        }

        $scope.SaveStoreItem = function (store) {
            if (FValidation.CheckControls("check-store" + store.StoreId)) {
                $scope.StoreFormConfig.SetObject(store);
                var storeId = $scope.StoreFormConfig.SaveObject();
                if (storeId > 0) {
                    ShowSuccessMessage("Cửa hàng được đổi thành công.");
                    $scope.ReloadGrid('Stores');
                }
            }
        }

        $scope.RuleFormConfig = new ObjectDataConfig("T_System_Rule", $scope);

        $scope.SaveRule = function (rule) {
            if (FValidation.CheckControls("check-rule" + rule.RuleId)) {
                $scope.RuleFormConfig.SetObject(rule);
                var ruleId = $scope.RuleFormConfig.SaveObject();
                if (ruleId > 0) {
                    ShowSuccessMessage("Thiết lập được đổi thành công.");
                    rule.IsEditing = false;
                }
            }
        }

        ///////////////////////////////////////////////////////////
        $scope.TemplateForm =
        {
            TemplateId: 1,
            TemplateName: "",
            DefaultBody: "",
            RuntimeBody: "",
            HtmlBody: "",
            Version: 0
        }

        $scope.InitEditor = function () {

            CKEDITOR.replace('editor', {
                language: 'vi',
                extraPlugins: 'autogrow',
                autoGrow_minHeight: 200,
                height: '500',
                removePlugins: 'resize'
                //autoGrow_maxHeight: 600
                //uiColor: '#9AB8F3'
            });

            CKEDITOR.instances.editor.on('change', function () {
                $scope.$apply(function () {
                    $scope.ChangeTemplate();
                });
            });

            //Get teams, sample data, replaced expression
            $scope.GetListPrintTerm();

            //Get template
            $scope.GetTemplate();
        }

        $scope.GetTemplate = function () {
            var template = $scope.TemplateFormConfig.GetObject($scope.TemplateForm.TemplateId);
            $scope.TemplateFormConfig.CopyFields(template, $scope.TemplateForm);
            $scope.TemplateForm.HtmlBody = $scope.ConvertTrustHtml($scope.TemplateForm.RuntimeBody);

            //alert(CKEDITOR.instances.editor.editable());

            CKEDITOR.instances.editor.setData($scope.TemplateForm.RuntimeBody);
        }

        $scope.GetDefaultTemplate = function () {
            $scope.TemplateForm.RuntimeBody = $scope.TemplateForm.DefaultBody;
            $scope.TemplateForm.HtmlBody = $scope.ConvertTrustHtml($scope.TemplateForm.RuntimeBody);
            //CKEDITOR.instances.editor.setData($scope.TemplateForm.RuntimeBody);
            CKEDITOR.instances.editor.editable().setHtml($scope.TemplateForm.RuntimeBody);
        }

        $scope.ChangeTemplate = function () {
            $scope.TemplateForm.HtmlBody = $scope.ConvertTrustHtml(CKEDITOR.instances.editor.getData());
        }

        $scope.SaveTemplate = function () {
            $scope.TemplateForm.RuntimeBody = CKEDITOR.instances.editor.getData();
            $scope.TemplateFormConfig.SetObject($scope.TemplateForm);
            var templateId = $scope.TemplateFormConfig.SaveObject();
            if (templateId > 0) {
                ShowSuccessMessage("Mẫu in được đổi thành công.");
            }
        }

        $scope.ConvertTrustHtml = function (html) {
            //html = html.Re
            html = html.replace(/{/g, '{{SampleData.');
            html = html.replace(/}/g, '}}');
            return $sce.trustAsHtml(html);
        };

        

        /*$scope.SampleData =
        {
            Ten_Cua_Hang: "Thegioididong",
            Dia_Chi_Cua_Hang: "P3, Q.11, TP. HCM",
            SDT_Cua_Hang: "083-333-444",
            Ngay_Xuat: "23-06-2016",
            Ngay_Thang_Nam: formatDate(new Date()),
            Ghi_Chu: "Đã nhận đủ hàng!",
            Ma_Don_Hang: "PX00010",
            Nhan_Vien_Thu_Ngan: "Thu thủy",
            Ma_Khach_Hang: "",
            Khach_Hang: "Thành Phong",
            Dia_Chi_Khach_Hang: "",
            STT: "1",
            Ma_Hang: "HH00016",
            Ten_Hang_Hoa: "Áo thun thái - xanh",
            So_Luong: "2",
            Don_Gia_Sau_Giam_Gia: "100,000",
            Thanh_Tien: "200,000",
            Tong_So_Luong: "2",
            Tong_Tien_Hang: "200,000",
            Giam_Gia_Tren_Hoa_Don: "10,000",
            Giam_Gia_PT_Tren_Hoa_Don: "",
            Tong_Thanh_Toan: "190,000",
            Da_Thanh_Toan: "190,000",
            Chua_Thanh_Toan: "0",
            Tien_Thua: "",
            Ma_Phieu_Nhap: "PN100012",
            Nha_Cung_Cap: "Cty SX Thái Tuấn",
            Ngay_Nhap: "19-05-2016",
            Nhan_Vien_Nhap_Hang: "Tuấn Vũ",
            Tong_Tien_Thue: "0",
            Ma_Phieu_Chi: "PC1000017",
            Ngay_Chi: "20-05-2016",
            Nguoi_Chi: "Thanh Thủy",
            Ten_Chi_Phi: "Tiền điện tháng 10",
            Loai_Chi_Phi: "Tiền điện nước",
            Ngay_Chuyen: "16-05-2016",
            Nhan_Vien_Chuyen_Hang: "Thành Phong",
            Tu_Kho: "Thegiodidong",
            Den_Kho: "Dienmayxanh"
        }*/

    }]);