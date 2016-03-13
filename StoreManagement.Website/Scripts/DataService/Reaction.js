
mdlCommon.controller('ReactionController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        
        $scope.Config.OrderBy = "REquation";
        $scope.Config.OrderDirection = 1;
              
        $scope.Form = { REquation: "", RDescription: "", IsRequireLight: "", IsRequireTemperature: "", IsRequirePressure: "", MinTemperature :""};

        //Implement for paging
        $scope.GetNumTotalRecords = function () {
            var result = AjaxSync(countAllReactionsUrl, '{ config: ' + JSON.stringify($scope.Config) + '}');
            if (!result) result = 0;
            return result;
        }

        $scope.GetListDataFromDB = function () {
            $scope.DataSet.Data = AjaxSync(getAllReactionsUrl, '{ config: ' + JSON.stringify($scope.Config) + '}');
        }

        $scope.SaveReaction = function () {

            if (FValidation.CheckControls("")) {

                var result = AjaxSync(saveReactionUrl, '{ reaction: ' + JSON.stringify($scope.Form) + '}');
                if (result != null) {
                    alert('Chemical has been inserted sucessfully!');
                    
                    $scope.CalculatedGridPara();

                    $scope.ResetForm();
                }
                else {
                    alert('Chemical has been inserted failed!');
                }

                
            }
        }

        $scope.ResetForm = function () {
            $scope.Form.REquation = "";
            $scope.Form.RDescription = "" ;
            $scope.Form.IsRequireLight = "";
            $scope.Form.IsRequireTemperature = "";
            $scope.Form.IsRequirePressure = "";
            $scope.Form.MinTemperature = "";
        }

        
    }]);