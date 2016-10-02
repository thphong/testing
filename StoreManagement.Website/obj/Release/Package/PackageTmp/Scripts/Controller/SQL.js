
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
            //$scope.SQLForm.DataResult = AjaxSync(g_executeSQLUrl, '{ sql: "' + $scope.SQLForm.SQLStatement + '"}');

            var formData = new FormData();
            formData.append('sql', $scope.SQLForm.SQLStatement);

            $.ajax({
                url: g_executeSQLUrl,
                type: 'POST',
                data: formData,
                processData: false,  // tell jQuery not to process the data
                contentType: false,  // tell jQuery not to set contentType
                success: function (data) {

                    $scope.$apply(function () {
                        $scope.SQLForm.DataResult = data;

                        $scope.SQLForm.HeaderResult = [];
                        if ($scope.SQLForm.DataResult[0]) {
                            for (var key in $scope.SQLForm.DataResult[0]) {
                                $scope.SQLForm.HeaderResult.push(key);
                            }
                        }
                        ShowSuccessMessage("SQL được thực thi thành công!");
                    });
                }
            });            
        }

        $scope.CancelSQL = function () {
            $scope.SQLForm.SQLStatement = "";
        }

    }]);