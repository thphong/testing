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
        
        $scope.SelectedUserId = -1;
        $scope.SelectedStoreId = -1;
        $scope.Filter = {
            SelectedMonth: ((new Date()).getMonth() + 1).toString(),
            SelectedYear: (new Date()).getFullYear().toString(),
            CurrentStore: "0",
            ProductGroup: "0"
        };

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

        $scope.BarChartBySeller = null;
        $scope.BindBarChartBySeller = function (content, listName) {
            setTimeout(function () {
                if ($scope.BarChartBySeller == null) {
                    $scope.BarChartBySeller = c3.generate({
                        bindto: '#chartReportBySeller',
                        data: { x: 'x', columns: [], type: "bar" },
                        axis: {
                            x: { label: 'Người bán', type: 'category' } /*this needed to load string x value*/
                            , y: { label: 'Doanh thu' }
                        },
                        bar: { width: { ratio: 0.5 } },
                        legend: { show: false }
                    });
                }

                if (listName.length > 1) {
                    $scope.BarChartBySeller.load({
                        columns: [listName, content]
                    });
                }
                else {
                    $scope.BarChartBySeller.unload();
                }
            }, 10);
        }

        $scope.$watch('DataSet.ReportBySeller.Data', function (newVal, oldVal) {
            var listData = newVal;
            var listName = ['x'];
            var content = ['Doanh thu'];
            for (var i = 0; i < listData.length; i++) {
                content.push(listData[i].Revenue);
                listName.push(listData[i].CashierName);
            }
            $scope.BindBarChartBySeller(content, listName);

        }, false);

        $scope.PieChartByStore = null;
        $scope.BindPieChart = function (content) {
            setTimeout(function () {
                if ($scope.PieChartByStore == null) {
                    $scope.PieChartByStore = c3.generate({
                        bindto: '#chartReportByStore',
                        data: {
                            columns: [],
                            type: "pie"
                        },
                        legend: {
                            position: "right"
                        }
                    });
                }
                if (content.length > 0) {
                    $scope.PieChartByStore.load({
                        columns: content
                    });
                }
                else {
                    $scope.PieChartByStore.unload();
                }
            }, 10);
        }

        $scope.$watch('DataSet.ReportByStore.Data', function (newVal, oldVal) {
            var listData = newVal;
            var content = [];
            for (var i = 0; i < listData.length; i++) {
                content[i] = [listData[i].StoreCode, listData[i].Revenue];
            }
            $scope.BindPieChart(content);

        }, false);

        $scope.BarChartByMonth = null;
        $scope.BindBarChartByMonth = function (revenue, order, listName) {
            setTimeout(function () {
                if ($scope.BarChartByMonth == null) {
                    $scope.BarChartByMonth = c3.generate({
                        bindto: '#chartReportByMonth',
                        data: { x: 'x', columns: [], types: { 'Doanh thu': 'bar', 'Đơn hàng': 'spline' }, axes: { 'Đơn hàng': 'y2' } },
                        axis: {
                            x: {
                                label: 'Ngày', type: 'category', tick: {
                                    rotate: 90,
                                    multiline: false
                                }
                            } /*this needed to load string x value*/
                            , y: {
                                label: 'Doanh thu'
                            }
                            , y2: {
                                show: true,
                                label: 'Đơn hàng',
                                tick: {
                                    format: d3.format('d')
                                }
                            }
                        },
                        bar: { width: { ratio: 0.5 } },
                        legend: { show: false }
                    });
                }

                if (listName.length > 1) {
                    $scope.BarChartByMonth.load({
                        columns: [listName, revenue, order]
                    });
                }
                else {
                    $scope.BarChartByMonth.unload();
                }
            }, 10);
        }

        $scope.$watch('DataSet.ReportByMonth.Data', function (newVal, oldVal) {
            var listData = newVal;
            var listName = ['x'];
            var revenue = ['Doanh thu'];
            var order = ['Đơn hàng'];
            for (var i = 0; i < listData.length; i++) {
                revenue.push(listData[i].Revenue);
                order.push(listData[i].NumOrders);
                listName.push(listData[i].Day);
            }
            $scope.BindBarChartByMonth(revenue, order, listName);

        }, false);

        $scope.BarChartByYear = null;
        $scope.BindBarChartByYear = function (revenue, order, listName) {
            setTimeout(function () {
                if ($scope.BarChartByYear == null) {
                    $scope.BarChartByYear = c3.generate({
                        bindto: '#chartReportByYear',
                        data: { x: 'x', columns: [], types: { 'Doanh thu': 'bar', 'Đơn hàng': 'spline' }, axes: { 'Đơn hàng': 'y2' }},
                        axis: {
                            x: {
                                label: 'Tháng', type: 'category'
                            } /*this needed to load string x value*/
                            , y: {
                                label: 'Doanh thu'
                            }
                            , y2: {
                                show: true,
                                label: 'Đơn hàng',
                                tick: {
                                    format: d3.format('d')
                                }
                            }
                        },
                        bar: { width: { ratio: 0.5 } },
                        legend: { show: false }
                    });
                }

                if (listName.length > 1) {
                    $scope.BarChartByYear.load({
                        columns: [listName, revenue, order]
                    });
                }
                else {
                    $scope.BarChartByYear.unload();
                }
            }, 10);
        }

        $scope.$watch('DataSet.ReportByYear.Data', function (newVal, oldVal) {
            var listData = newVal;
            var listName = ['x'];
            var revenue = ['Doanh thu'];
            var order = ['Đơn hàng'];
            for (var i = 0; i < listData.length; i++) {
                revenue.push(listData[i].Revenue);
                order.push(listData[i].NumOrders);
                listName.push(listData[i].Month);
            }
            $scope.BindBarChartByYear(revenue, order, listName);

        }, false);
    }]);
