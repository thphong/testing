

mdlCommon.controller('FilesController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.AdditionalFilter = {
            FileTypeId: "0"
        };

        $scope.FilesFormConfig = new ObjectDataConfig("T_Master_File", $scope);
        $scope.FilesFormConfig.CheckCanCreateObject();

        $scope.IsShowFilesDetail = false;

        $scope.FilesForm = {
            FileId: -1,
            FileName: "",
            StoreId: $scope.CurrentStore,
            FileTypeId: "0",
            FileTypeName: "",
            FilePath: "",
            IsActive: 1,
            _CanUpdate: true,
            _CanDelete: true,
            Version: 0
        };

        $scope.ResetFilesForm = function () {
            $scope.FilesForm.FileId = -1;
            $scope.FilesForm.FileName = "";
            $scope.FilesForm.StoreId = $scope.CurrentStore;
            $scope.FilesForm.FileTypeId = "0";
            $scope.FilesForm.FileTypeName = "";
            $scope.FilesForm.FilePath = "";          
            $scope.FilesForm.IsActive = 1;
            $scope.FilesForm._CanUpdate = true;
            $scope.FilesForm._CanDelete = true;
            $scope.FilesForm.Version = 0;
        }

       
        $scope.AddFile = function () {
            FValidation.ClearAllError();
            $scope.ResetFilesForm();
            $("#uploadfile").val("");
            $('#filesModal').modal('show');
        }

        $scope.CloseFilesDetail = function () {
        }

        $scope.DeleteFiles = function (file) {
            if (confirm("Bạn có muốn xóa tài liệu " + file.FileName + "?")) {
                if ($scope.FilesFormConfig.DeleteObject(file.FileId)) {
                    $scope.ReloadGrid('Files');
                    ShowSuccessMessage("Tài liệu được xóa thành công!");
                }
            }
        }

        
        $scope.SaveFilesForm = function (status) {
            if (FValidation.CheckControls("check-files")) {
                //===========================================
                var result = true;
                if ($scope.FilesForm.FileId <= 0) {
                    if ($("#uploadfile")[0].files.length == 0) {
                        ShowErrorMessage("Chưa chọn tài liệu"); return;
                    }
                    result = $scope.AddNewFile();
                } else {
                    result = $scope.SaveFile();
                }
                //===========================================
                if (result) {
                    $('#filesModal').modal('hide');
                    ShowSuccessMessage("Tài liệu được lưu thành công!");
                    $scope.ReloadGrid('Files');
                }
            }
        }

        $scope.AddNewFile = function () {
            var result;
            if ($("#uploadfile")[0].files.length > 0) {
                var file = $(uploadfile)[0].files[0];
                var formData = new FormData();
                formData.append('file', file);
                formData.append('fileType', $scope.FilesForm.FileTypeId);
                formData.append('fileName', $scope.FilesForm.FileName);
                $.ajax({
                    url: g_uploadFileUrl,
                    type: 'POST',
                    data: formData,
                    async: false,
                    processData: false,  // tell jQuery not to process the data
                    contentType: false,  // tell jQuery not to set contentType
                    success: function (data) {
                        if (typeof (data) == 'string' && data.startsWith("#error")) {
                            ShowErrorMessage(data);
                            result = null;
                        }
                        else {
                            result = data;
                        }
                    }
                });
                //set image id to DataObject          
            }
            //===============================
            if (result == null) return false;
            if (result.id == 0) { ShowErrorMessage("Không có tài liệu được tải"); return false; }
            return true;
        }

        $scope.SaveFile = function () {
            $scope.FilesFormConfig.SetObject($scope.FilesForm);
            //FilesFormConfig
            var fileId = $scope.FilesFormConfig.SaveObject();
            if (fileId > 0) {
                return true;
            }
            return false;
        }
        $scope.ShowFilesDetail = function (file) {
            //Load file form
            $scope.GetFilesDetail(file);
            $scope.FilesForm._CanUpdate = file._CanUpdate;
            $scope.FilesForm._CanDelete = file._CanDelete;
            $("#uploadfile").val("");
            $('#filesModal').modal('show');
        }

        $scope.GetFilesDetail = function (file) {
            $scope.FilesFormConfig.SetObject($scope.FilesForm);
            var object = $scope.FilesFormConfig.GetObject(file.FileId);
            $scope.FilesFormConfig.CopyFields(object, $scope.FilesForm);
            $scope.FilesForm.FileTypeName = file.FileTypeName;
        }

       
    }]);