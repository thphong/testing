
$(document).ready(function () {
    $('input.datepicker').datepicker({ format: 'dd-mm-yyyy'/*, startDate: '23-03-2016'*/ });
});

mdlCommon.controller('RevenueController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });


        $scope.CurrentTab = "ReportBySeller";

        $scope.SetCurrentTab = function (tab) {
            if (tab != $scope.CurrentTab) {
                $scope.CurrentTab = tab;
            }
        }

        $scope.SetFilterRangeDate(2);

        $scope.SelectedUserId = -1;
        $scope.SelectedStoreId = -1;

        $scope.SelectUserId = function (user) {
            if ($scope.SelectedUserId == user.UserId) {
                $scope.SelectedUserId = -1;
            }
            else {
                $scope.SelectedUserId = user.UserId;
            }
        }

        $scope.SelectStoreId = function (store) {
            if ($scope.SelectedStoreId == store.StoreId) {
                $scope.SelectedStoreId = -1;
            }
            else {
                $scope.SelectedStoreId = store.StoreId;
            }
        }

        $scope.BindBarChart = function (content, listName) {
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
                        ratio: listName.length < 10 ? listName.length / 10 : 0.9  // this makes bar width 50% of length between ticks
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
        }

        $scope.BindPieChart = function (content) {
            c3.generate({
                bindto: '#chartReportByStore',
                data: {
                    columns: content,
                    type: "pie"
                },
                legend: {
                    position: "right"
                }
            });
        }

        $scope.$watch('DataSet.ReportBySeller.Data', function (newVal, oldVal) {
            var listData = newVal;
            var listName = [];
            var content = [];
            for (var i = 0; i < listData.length; i++) {
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
            $scope.BindBarChart(content, listName);

        }, false);

        $scope.$watch('DataSet.ReportByStore.Data', function (newVal, oldVal) {
            var listData = newVal;
            var content = [];
            for (var i = 0; i < listData.length; i++) {
                content[i] = [listData[i].StoreCode, listData[i].Revenue];
            }
            $scope.BindPieChart(content);

        }, false);

    }]);
