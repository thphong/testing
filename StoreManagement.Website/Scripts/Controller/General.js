mdlCommon.controller('GeneralController',
['$scope', '$filter', '$controller', '$interpolate',
    function ($scope, $filter, $controller, $interpolate) {
        $controller('ctrlPaging', { $scope: $scope });

        //General info
        $scope.ConfigList = new GridViewConfig("");
        $scope.ConfigList.GridDataAction = "getall";
        $scope.ConfigList.GridDataType = "function";
        $scope.ConfigList.GridDataObject = "dbo.UFN_Report_General";
        $scope.ConfigList.GridDefinedColums = "Revenue;NumOrder;NumSoldProduct;ReturnAmount;LongInventory;OutOfQuantity;UnderMin;OverMax;TotalProduct;NotInputPrice;NotInputCost;NotInputGroup";
        $scope.ConfigList.GridParameters = $scope.CurrentUser + "," + $scope.CurrentStore;
        
        $scope.GeneralInfo = $scope.ConfigList.GetListData()[0];

        //Chart
        $scope.SetFilterRangeDate(1, "");
        $scope.ConfigList.GridDataObject = "dbo.UFN_Report_Revenue_By_Day";
        $scope.ConfigList.GridDefinedColums = "Day;Revenue;LastRevenue";
        $scope.ConfigList.GridParametersExpression = "{{CurrentUser}},dbo.UFN_System_GetDateTime(''{{FilterRangeDate.StartDate}}'', ''dd-MM-yyyy''),dbo.UFN_System_GetDateTime(''{{FilterRangeDate.EndDate}}'', ''dd-MM-yyyy''), {{CurrentStore}}";
        
        $scope.BarChart = null;
        $scope.BindBarChart = function (thisWeek, lastWeek, listName) {
            setTimeout(function () {
                if ($scope.BarChart == null) {
                    $scope.BarChart = c3.generate({
                        bindto: '#chartReportByDay',
                        data: { x: 'x', columns: [], type: "bar", order: null },
                        axis: {
                            x: { label: 'Ngày', type: 'category' } //this needed to load string x value
                            , y: { label: 'Doanh thu' }
                        },
                        bar: { width: { ratio: 0.5 } }
                    });
                }

                if (listName.length > 1) {
                    $scope.BarChart.load({
                        columns: [listName, thisWeek, lastWeek]
                    });
                }
                else {
                    $scope.BarChart.unload();
                }
            }, 10);
        }

        $scope.InitChart = function () {
            $scope.ConfigList.EvaluateFieldExpression($interpolate, $scope);
            var listData = $scope.ConfigList.GetListData();
            var listName = ['x'];
            var thisWeek = ['Tuần này'];
            var lastWeek = ['Tuần trước'];
            for (var i = 0; i < listData.length; i++) {
                thisWeek.push(listData[i].Revenue);
                lastWeek.push(listData[i].LastRevenue);
                listName.push(listData[i].Day);
            }
            $scope.BindBarChart(thisWeek, lastWeek, listName);

        };
        $scope.InitChart();

        //Revenue in week
        $scope.ConfigList.GridDataObject = "dbo.UFN_Report_Profit_By_Store";
        $scope.ConfigList.GridDefinedColums = "Quantity;Revenue;ReturnAmount;Cost;Profit";
        $scope.ConfigList.GridParametersExpression = "{{CurrentUser}},dbo.UFN_System_GetDateTime(''{{FilterRangeDate.StartDate}}'', ''dd-MM-yyyy''),dbo.UFN_System_GetDateTime(''{{FilterRangeDate.EndDate}}'', ''dd-MM-yyyy''), {{CurrentStore}}";
        
        $scope.Revenue =
        {
            Data: {},
            DateRangeText: "Tuần này"
        }

        $scope.ShowRevenue = function()
        {
            $scope.ConfigList.EvaluateFieldExpression($interpolate, $scope);
            $scope.Revenue.Data = $scope.ConfigList.GetListData()[0];
        }

        $scope.ShowRevenue();

        $scope.ChangeDateRange = function(option, text)
        {
            $scope.Revenue.DateRangeText = text;
            $scope.SetFilterRangeDate(option, '');
            $scope.ShowRevenue();
        }
    }]);