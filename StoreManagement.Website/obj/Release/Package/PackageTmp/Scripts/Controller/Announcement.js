mdlCommon.controller('AnnouncementController',
['$scope', '$filter', '$controller', '$sce',
    function ($scope, $filter, $controller, $sce) {
        $controller('ctrlPaging', { $scope: $scope });
        

        $scope.AnnouncementFormConfig = new ObjectDataConfig("T_Trans_Announcement", $scope);
        $scope.AnnouncementFormConfig.CheckCanCreateObject();

        $scope.ConvertTrustHtml = function (html) {
            return $sce.trustAsHtml(html);
        };

        $scope.AnnouncementForm =
        {
            AnnouncementId: -1,
            StoreId: "0",
            Title: "",
            Body: "",
            Version: 0
        }

        $scope.ResetAnnouncementForm = function()
        {
            $scope.AnnouncementForm.AnnouncementId = -1;
            $scope.AnnouncementForm.StoreId = "0";
            $scope.AnnouncementForm.Title = "";
            $scope.AnnouncementForm.Body = "";
            $scope.AnnouncementForm.Version = 0;
            CKEDITOR.instances.editor.editable().setHtml("");
        }

        $scope.InitEditor = function () {

            CKEDITOR.replace('editor', {
                language: 'vi',
                extraPlugins: 'autogrow',
                autoGrow_minHeight: 200,
                height: '200',
                removePlugins: 'resize'
                //autoGrow_maxHeight: 600
                //uiColor: '#9AB8F3'
            });
        }

        $scope.SaveAnnouncementForm = function ()
        {
            if (FValidation.CheckControls("check-announce")) {
                $scope.AnnouncementForm.Body = CKEDITOR.instances.editor.getData();
                if (!$scope.AnnouncementForm.Body) {
                    ShowErrorMessage("Vui lòng nhập nội dung.");
                }
                else {
                    $scope.AnnouncementFormConfig.SetObject($scope.AnnouncementForm);
                    var id = $scope.AnnouncementFormConfig.SaveObject();
                    if (id > 0) {
                        ShowSuccessMessage("Thông báo được lưu thành công!");
                        $scope.ResetAnnouncementForm();
                        $("button[data-dismiss='modal']:visible").click();
                        $scope.ReloadGrid("Announcements");
                    }
                }
            }
        }

        $scope.EditAnnouncement = function (announce)
        {
            $scope.AnnouncementFormConfig.CopyFields(announce, $scope.AnnouncementForm);
            $scope.AnnouncementForm.Version = announce.AnnounceVersion;
            CKEDITOR.instances.editor.editable().setHtml(announce.Body);
        }
    }]);