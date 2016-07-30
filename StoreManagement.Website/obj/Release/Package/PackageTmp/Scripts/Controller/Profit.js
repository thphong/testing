mdlCommon.controller('ProfitController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        $controller('ctrlPaging', { $scope: $scope });

        $scope.CurrentTab = "ReportByTime";

        $scope.SetCurrentTab = function (tab) {
            if (tab != $scope.CurrentTab) {
                $scope.CurrentTab = tab;
            }
        }

        $scope.Filter = {
            ReportGroupBy: "d",
            CurrentStore: "0",
            ProductGroup: "0",
            PreStartDate: "",
            PreEndDate: ""
        };
        
        $scope.BarChartByTime = null;
        $scope.BindBarChartByTime = function (cost, profit, listName) {
            setTimeout(function () {
                if ($scope.BarChartByTime == null) {
                    $scope.BarChartByTime = c3.generate({
                        bindto: '#chartReportByTime',
                        data: { x: 'x', columns: [], type: "bar", groups: [['Lãi', 'Vốn']], order: null },
                        axis: {
                            x: { label: 'Thời gian', type: 'category' } //this needed to load string x value
                            , y: { label: 'Doanh thu' }
                        },
                        bar: { width: { ratio: 0.5 } },
                        legend: { position: "right" }
                    });
                }

                if (listName.length > 1) {
                    $scope.BarChartByTime.load({
                        columns: [listName, cost, profit ]
                    });
                }
                else {
                    $scope.BarChartByTime.unload();
                }
            }, 10);
        }

        $scope.$watch('DataSet.ReportByTime.Data', function (newVal, oldVal) {
            var listData = newVal;
            var listName = ['x'];
            var cost = ['Vốn'];
            var profit = ['Lãi'];
            for (var i = 0; i < listData.length; i++) {
                cost.push(listData[i].Cost);
                profit.push(listData[i].Profit);
                listName.push(listData[i].GroupBy);
            }
            $scope.BindBarChartByTime(cost, profit, listName);

        }, false);

        $scope.BarChartByProduct = null;
        $scope.BindBarChartByProduct = function (cost, profit, listName) {
            setTimeout(function () {
                if ($scope.BarChartByProduct == null) {
                    $scope.BarChartByProduct = c3.generate({
                        bindto: '#chartReportByProduct',
                        data: { x: 'x', columns: [], type: "bar", groups: [['Lãi', 'Vốn']], order: null },
                        axis: {
                            x: { label: 'Sản phẩm', type: 'category' } //this needed to load string x value
                            , y: { label: 'Doanh thu' }
                        },
                        bar: { width: { ratio: 0.5 } },
                        legend: { position: "right" }
                    });
                }
                if (listName.length > 1) {
                    $scope.BarChartByProduct.load({
                        columns: [listName, cost, profit]
                    });
                }
                else {
                    $scope.BarChartByProduct.unload();
                }
            }, 10);
        }

        $scope.$watch('DataSet.ReportByProduct.Data', function (newVal, oldVal) {
            var listData = newVal;
            var listName = ['x'];
            var cost = ['Vốn'];
            var profit = ['Lãi'];
            for (var i = 0; i < listData.length; i++) {
                cost.push(listData[i].Cost);
                profit.push(listData[i].Profit);
                listName.push(listData[i].ProductCode);
            }
            $scope.BindBarChartByProduct(cost, profit, listName);

        }, false);

        $scope.BarChartByStore = null;
        $scope.BindBarChartByStore = function (cost, profit, listName) {
            setTimeout(function () {
                if ($scope.BarChartByStore == null) {
                    $scope.BarChartByStore = c3.generate({
                        bindto: '#chartReportByStore',
                        data: { x: 'x', columns: [], type: "bar", groups: [['Lãi', 'Vốn']], order: null },
                        axis: {
                            x: { label: 'Cửa hàng', type: 'category' } //this needed to load string x value
                            , y: { label: 'Doanh thu' }
                        },
                        bar: { width: { ratio: 0.5 } },
                        legend: { position: "right" }
                    });
                }
                if (listName.length > 1) {
                    $scope.BarChartByStore.load({
                        columns: [listName, cost, profit]
                    });
                }
                else {
                    $scope.BarChartByStore.unload();
                }
            }, 10);
        }

        $scope.$watch('DataSet.ReportByStore.Data', function (newVal, oldVal) {
            var listData = newVal;
            var listName = ['x'];
            var cost = ['Vốn'];
            var profit = ['Lãi'];
            for (var i = 0; i < listData.length; i++) {
                cost.push(listData[i].Cost);
                profit.push(listData[i].Profit);
                listName.push(listData[i].StoreCode);
            }
            $scope.BindBarChartByStore(cost, profit, listName);

        }, false);

        $scope.Abs = function(value)
        {
            return Math.abs(value);
        }
    }]);
