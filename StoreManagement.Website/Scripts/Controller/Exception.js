mdlCommon.controller('ExceptionController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.AdditionalFilter = {
            ExceptionType: "0"
        };

        $scope.ExceptionFormConfig = new ObjectDataConfig("T_System_Exception_Log", $scope);
        $scope.ExceptionFormConfig.CheckCanCreateObject();

        $scope.ExceptionForm = {
            Id: -1,
            ObjectName: "",
            ErrorMessage: "",
            Data: "",
            Source : "",
            IsResolve : 0
        }

        $scope.ResetExceptionForm = function()
        {
            $scope.ExceptionForm.Id = -1;
            $scope.ExceptionForm.ObjectName = "";
            $scope.ExceptionForm.ErrorMessage = "";
            $scope.ExceptionForm.Data = "";
            $scope.ExceptionForm.Source = "";
            $scope.ExceptionForm.IsResolve = 0;
        }

        $scope.SaveBug = function ()
        {
            if (FValidation.CheckControls("check-bug")) {
                $scope.ExceptionFormConfig.SetObject($scope.ExceptionForm);
                if ($scope.ExceptionFormConfig.SaveObject()) {
                    ShowSuccessMessage("Bug đã được tạo :(");
                    $scope.ResetExceptionForm();
                    $("button[data-dismiss='modal']:visible").click();
                    $scope.ReloadGrid('Exceptions');
                }
            }
        }

        $scope.ResolveBug = function(bug)
        {
            if (FValidation.CheckControls("Ex" + bug.Id)) {
                bug.IsResolve = 1;
                bug.Hero = $scope.CurrentUser;
                $scope.ExceptionFormConfig.SetObject(bug);
                if ($scope.ExceptionFormConfig.SaveObject()) {
                    ShowSuccessMessage("Chúc mừng bạn đã thành dũng sĩ diệt bug!");
                    $scope.ReloadGrid('Exceptions');
                }
            }
        }

    }]);