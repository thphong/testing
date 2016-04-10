mdlCommon.controller('RevenueController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });
        
        $scope.SetFilterRangeDate(2);
        
        $scope.SelectedUserId = -1;

        $scope.SelectUserId = function(user)
        {
            if($scope.SelectedUserId == user.UserId)
            {
                $scope.SelectedUserId = -1;
            }
            else {
                $scope.SelectedUserId = user.UserId;
            }
        }
        
        $scope.$watch('DataSet.ReportBySeller.Data', function (newVal, oldVal) {
            var listData = newVal;
            var listName = [];
            var content = [];
            for(var i = 0; i<listData.length; i++)
            {
                content[i] = [listData[i].CashierName];
                listName.push(listData[i].CashierName);
                for (var j = 0; j < listData.length; j++) {
                    if (i != j) {
                        content[i].push(0);
                    }
                    else {
                        content[i].push(listData[i].Revenue);
                    }
                }
            }
            /*$scope.ChartReportBySeller.unload();
            $scope.ChartReportBySeller.load({
                columns: content,
                categories: listName
            });
            $scope.ChartReportBySeller.groups([listName]);*/
            c3.generate({
                bindto: '#chartReportBySeller',
                data: {
                    columns: content,
                    type: "bar",
                    groups: [listName]
                },
                axis: {
                    x: {
                        label: 'Người bán',
                        type: 'category', // this needed to load string x value
                        categories: listName
                    },
                    y: {
                        label: 'Doanh thu'
                    }
                },
                bar: {
                    width: {
                        ratio: listName.length < 10 ? listName.length/10 : 0.9  // this makes bar width 50% of length between ticks
                    }
                },
                tooltip: {
                    contents: function (d, defaultTitleFormat, defaultValueFormat, color) {
                        var name, value;
                        for (var i = 0 ; i < d.length; i++) {
                            if (d[i].value > 0) {
                                name = d[i].name;
                                value = $filter('currency')(d[i].value, "", 0);
                                break;
                            }
                        }
                        return '<table class="c3-tooltip"><tbody><tr><th>' + name + '</th></tr><tr><td class="value">' + value + '</td></tr></tbody></table>';
                    }
                },
                legend: {
                    show: false
                }
            });
        }, false);

    }]);