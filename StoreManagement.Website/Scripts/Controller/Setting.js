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
['$scope', '$filter', '$controller', '$sce',
    function ($scope, $filter, $controller, $sce) {
        $controller('ctrlPaging', { $scope: $scope });
        $controller('ProductGroupController', { $scope: $scope });
        $controller('PrintController', { $scope: $scope });

        $scope.CurrentTab = "Users";

        $scope.IsShownUserRolesModal = false;
        $scope.IsShownTemplateTermsModal = false;
        $scope.IsShownPromotionStoreModal = false;

        $scope.SetShownUserRolesModal = function (isShown) {
            $scope.IsShownUserRolesModal = isShown;
        }

        $scope.SetShownTemplateTermsModal = function (isShown) {
            $scope.IsShownTemplateTermsModal = isShown;
        }

        $scope.SetShownPromotionStoreModal = function (isShown) {
            $scope.IsShownPromotionStoreModal = isShown;
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
            IsActive: 1,
            StoreId: $scope.CurrentStore
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
            $scope.UserForm.StoreId = $scope.CurrentStore;
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
                if ($scope.UserStoreFormConfig.DeleteObject(userRole.Id)) {
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
            Version: 0,
            IsActive: 1
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
            $scope.StoreForm.IsActive = 1;
        }

        $scope.StoreFormConfig = new ObjectDataConfig("T_Master_Stores", $scope);
        $scope.CanAddStore = $scope.StoreFormConfig.CheckField('ADD_STORE');
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

        $scope.DeleteDataStore = function () {
            if (confirm("Bạn có muốn xóa toàn bộ dữ liệu của cửa hàng '" + $scope.StoreForm.StoreName + "'?")) {
                $scope.StoreForm.TriggerDeleteSampleData = parseInt($scope.StoreForm.Version) + 1;
                $scope.StoreFormConfig.SetObject($scope.StoreForm);
                var storeId = $scope.StoreFormConfig.SaveObject();
                if (storeId > 0) {
                    ShowSuccessMessage("Tất cả dữ liệu của cửa hàng '" + $scope.StoreForm.StoreName + "' được xóa thành công.");
                }
            }
        }

        $scope.CreateSampleDataStore = function () {
            if (confirm("Bạn có muốn tạo dữ liệu mẫu cho cửa hàng '" + $scope.StoreForm.StoreName + "'?")) {
                $scope.StoreForm.TriggerCreateSampleData = parseInt($scope.StoreForm.Version) + 1;
                $scope.StoreFormConfig.SetObject($scope.StoreForm);
                var storeId = $scope.StoreFormConfig.SaveObject();
                if (storeId > 0) {
                    ShowSuccessMessage("Dữ liệu của cửa hàng '" + $scope.StoreForm.StoreName + "' được tạo thành công.");
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
            TemplateId: "0",
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

        //Promotion
        $scope.SelectedPromotion = {
            Id: -1,
            PromoteName : ""
        };

        $scope.PromotionConfig = new ObjectDataConfig("T_Master_Promotion", $scope);
        $scope.PromotionStoreConfig = new ObjectDataConfig("T_Trans_Promotion_Store", $scope);

        $scope.SavePromotion = function(promotion)
        {
            if (FValidation.CheckControls("check-promotion" + promotion.Id)) {
                $scope.PromotionConfig.SetObject(promotion);
                var id = $scope.PromotionConfig.SaveObject();
                if (id > 0) {
                    ShowSuccessMessage("Chương trình khuyến mãi được lưu thành công.");
                }
            }
        }

        $scope.SwitchAppliedStore = function(item)
        {
            item.IsApplied = 1 - item.IsApplied;
            $scope.PromotionStoreConfig.SetObject(item);
            var id = $scope.PromotionStoreConfig.SaveObject();
            if (id > 0) {
                ShowSuccessMessage("Thay đổi được lưu thành công.");
            }
        }

    }]);