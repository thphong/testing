
mdlCommon.controller('SQLController',
['$scope', '$filter', '$controller', '$interpolate', '$sce',
    function ($scope, $filter, $controller, $interpolate, $sce) {

        $scope.SQLForm =
        {
            SQLStatement: "select * from T_Master_User",
            DataResult: [],
            HeaderResult: []
        }

        $scope.ExecuteSQL = function () {
            $scope.SQLForm.DataResult = AjaxSync(g_executeSQLUrl, '{ sql: "' + $scope.SQLForm.SQLStatement + '"}');
            $scope.SQLForm.HeaderResult = [];
            if ($scope.SQLForm.DataResult[0]) {
                for (var key in $scope.SQLForm.DataResult[0]) {
                    $scope.SQLForm.HeaderResult.push(key);
                }
            }
            ShowSuccessMessage("SQL được thực thi thành công!");
        }

        $scope.CancelSQL = function () {
            $scope.SQLForm.SQLStatement = "";
        }

    }]);