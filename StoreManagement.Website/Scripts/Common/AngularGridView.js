var _CurrentGridId = "";
var _ListGridIds = [];
var _DropdownConfigs = {};
var _GridConfigData = {};


//Control for Gridview

mdlCommon.directive('gridPagingFor', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        var gridId = attributes.gridPagingFor;
        element.append(
             '<ul class="pagination" ng-if="DataSet.' + gridId + '.TotalItems > 0" style="margin-top: 0px">'
            + '<li ng-class="{disabled: Config.' + gridId + '.CurrentPage == 1}" ng-click="GridChangePageIndex(1,\'' + gridId + '\')" title="Page 1">'
            + '<a href=""> &laquo; </a>'
            + '</li>'
            + '<li ng-if="Config.' + gridId + '.StartIndex > 1" ng-click="GridChangePageIndex(Config.' + gridId + '.StartIndex-1,\'' + gridId + '\')">'
            + '<a href=""> ...  </a>'
            + '</li>'
            + '<li class="PagingItem" ng-repeat="index in Config.' + gridId + '.ListPageIndex" ng-class="{active: index==Config.' + gridId + '.CurrentPage }" ng-click="GridChangePageIndex(index, \'' + gridId + '\')">'
            + '<a href=""> {{index}} </a>'
            + '</li>'
            + '<li class="PagingItem" ng-if="Config.' + gridId + '.EndIndex < Config.' + gridId + '.NumOfPage" ng-click="GridChangePageIndex(Config.' + gridId + '.EndIndex+1, \'' + gridId + '\')">'
            + '<a href=""> ...  </a>'
            + '</li>'
            + '<li class="PagingItem" ng-class="{disabled: Config.' + gridId + '.CurrentPage==Config.' + gridId + '.NumOfPage}" ng-click="GridChangePageIndex(Config.' + gridId + '.NumOfPage, \'' + gridId + '\')" title="Page {{Config.' + gridId + '.NumOfPage}}">'
            + ' <a href=""> &raquo; </a>'
            + '</li>'
            + '</ul>');
    }
    return directive;
});

mdlCommon.directive('monthControl', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        var gridId = attributes.gridPagingFor;
        for (var i = 1; i <= 12; i++) {
            element.append('<option value="' + i + '">Tháng ' + i + '</option>');
        }
    }
    return directive;
});


mdlCommon.directive('yearControl', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        var minYear = parseInt(attributes.yearControl);
        var currentYear = (new Date()).getFullYear();
        for (var i = minYear ; i <= 0 ; i++) {

            element.append('<option value="' + (i + currentYear) + '">' + (i + currentYear) + '</option>');
        }
    }
    return directive;
});

mdlCommon.directive('gridPageSizeFor', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        var gridId = attributes.gridPageSizeFor;
        element.append('<div class="input-group">  <span class="input-group-addon"> <span> Số dòng</span> / <span > Tổng</span> <span ng-bind="DataSet.' + gridId + '.TotalItems"></span> : </span>'
           + '<select class="form-control input-sm" ng-model="Config.' + gridId + '.NumOfItemOnPage" ng-change="GridChangeNumRowsOnPage(\'' + gridId + '\')" data-ng-options="num as num for num in ListNumOfItem" style="width: auto">'
           + '</select> '
           + '</div>');
    }
    return directive;
});

mdlCommon.directive('gridExportImportFor', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        var gridId = attributes.gridExportImportFor;
        var template = attributes.gridExportTemplate;
        element.append('<button class="btn btn-success btn-primary" ng-click="ExportExcel(\'' + gridId + '\', \'' + template + '\')">'
                    + '<i class="fa fa-download white"></i>'
                    + '<span>Xuất Excel</span>'
                    + '</button>');
    }
    return directive;
});


mdlCommon.directive('ngEnter', function () {
    return function (scope, element, attrs) {
        element.bind("keydown keypress", function (event) {
            if (event.which === 13) {
                scope.$apply(function () {
                    scope.$eval(attrs.ngEnter);
                });
                event.preventDefault();
            }
        });
    };
});

mdlCommon.directive('checkInteger', function () {
    return function (scope, element, attrs) {
        element.bind("change", function (event) {
            var value = $(this).val();
            value = parseInt(value);
            if (value) {
                $(this).val(value);
            }
            else {
                $(this).val("0");
            }
        });
    };
});

mdlCommon.directive('checkCurrency', ['$filter', function ($filter) {
    return function (scope, element, attrs) {
        element.bind("keydown", function (event) {
            var key = String.fromCharCode(event.keyCode);
            if (key >= '0' && key <= '9') {
                var value = $(this).val().replace(/,/g, '') + key;
                value = $filter('currency')(value, "", 0);
                if (value) {
                    $(this).val(value);
                }
            }
            if (event.keyCode != 37 && event.keyCode != 38 && event.keyCode != 39 && event.keyCode != 40
                && event.keyCode != 32 && event.keyCode != 46) {
                event.preventDefault();
            }
        });
    };
}]);

mdlCommon.directive('gridFilterFor', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        var gridId = attributes.gridFilterFor;
        var placeHolderMessage = attributes.placeHolderMessage;
        if (!placeHolderMessage) {
            placeHolderMessage = "Nhập dữ liệu để tìm kiếm";
        }
        element.append('<div class="input-group" style="z-index:0">'
        + '<input type="text" class="form-control input-sm" placeholder="' + placeHolderMessage + '" ng-model="Config.' + gridId + '.FilterBy" ng-enter="GridFilter(\'' + gridId + '\')">'
        + '<span class="input-group-btn">'
        + '<button class="btn btn-primary input-sm" type="button" ng-click="GridFilter(\'' + gridId + '\')"><i class="fa fa-search"></i></button>'
        + '</span>'
        + '</div>');
    }
    return directive;
});

mdlCommon.directive('gridData', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        window._CurrentGridId = attributes.gridData;
        if ($.inArray(window._CurrentGridId, window._ListGridIds) == -1) {
            window._ListGridIds.push(window._CurrentGridId);

            _GridConfigData[window._CurrentGridId] = new GridViewConfig(window._CurrentGridId);

            element.after('<span ng-init="InitVisibleGrid(\'' + window._CurrentGridId + '\');"></span>');

        }
        else {
            alert("Grid with id '" + window._CurrentGridId + "' is duplicted, please change to new id");
        }
    }
    return directive;
});

mdlCommon.directive('gridDataType', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        _GridConfigData[window._CurrentGridId].GridDataType = attributes.gridDataType;
    }
    return directive;
});

mdlCommon.directive('gridDataAction', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        _GridConfigData[window._CurrentGridId].GridDataAction = attributes.gridDataAction;
    }
    return directive;
});

mdlCommon.directive('gridDataObject', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        _GridConfigData[window._CurrentGridId].GridDataObject = attributes.gridDataObject;
    }
    return directive;
});

mdlCommon.directive('gridFilterCondition', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        _GridConfigData[window._CurrentGridId].GridFilterConditionExpression =
            _GridConfigData[window._CurrentGridId].NormalizeColumName(attributes.gridFilterCondition);


    }
    return directive;
});

mdlCommon.directive('gridSortCondition', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        _GridConfigData[window._CurrentGridId].GridSortCondition =
            _GridConfigData[window._CurrentGridId].NormalizeColumName(attributes.gridSortCondition);
    }
    return directive;
});

mdlCommon.directive('gridSumCollection', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        _GridConfigData[window._CurrentGridId].GridSumColums =
            _GridConfigData[window._CurrentGridId].NormalizeColumName(attributes.gridSumCollection);
    }
    return directive;
});

mdlCommon.directive('gridParameters', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        _GridConfigData[window._CurrentGridId].GridParametersExpression =
            _GridConfigData[window._CurrentGridId].NormalizeColumName(attributes.gridParameters);
    }
    return directive;
});


mdlCommon.directive('gridDefinedColum', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        var definedColum = attributes.gridDefinedColum;
        var gridId = window._CurrentGridId;

        //append defined colums
        var existedcolums = _GridConfigData[window._CurrentGridId].GridDefinedColums;
        if (existedcolums) {
            existedcolums += ";";
        }
        _GridConfigData[window._CurrentGridId].GridDefinedColums = existedcolums + definedColum;

        //remove alias in colum for sort
        definedColum = definedColum.split(",")[0];

        element.append(' <a href="" ng-click="GridSortBy(\'' + definedColum + '\', \'' + gridId + '\')">'
                       + '<i style="padding-left: 4px;" class="fa " ng-class="{\'fa-sort-up\': Config.' + gridId + '.OrderBy == \'' + definedColum + '\' && Config.' + gridId + '.OrderDirection > 0,' +
                                                        ' \'fa-sort-down\': Config.' + gridId + '.OrderBy == \'' + definedColum + '\' && Config.' + gridId + '.OrderDirection < 0,' +
                                                         '\'fa-sort\': Config.' + gridId + '.OrderBy != \'' + definedColum + '\' }">'
                       + '</i>'
                       + '</a>');
        return null;
    }
    return directive;
});

//Control for Dropdown
mdlCommon.directive('dropdownMasterTable', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {

        /*var dropdownConfig = new DropdownConfig(element, attributes);
        _DropdownConfigs.push(dropdownConfig);
        dropdownConfig.BindBody();*/

        var dropdownId = "dropdown" + parseInt(Math.random() * 1000000);
        element.attr("dropdown-id", dropdownId);
        element.after('<span ng-init="InitVisibleDropdown(\'' + dropdownId + '\');"></span>');

        var configList = new GridViewConfig(dropdownId);
        var valueField = attributes.dropdownValueField;
        var nameField = attributes.dropdownNameField;
        configList.GridDataAction = "getall";
        configList.GridDataObject = attributes.dropdownMasterTable;
        configList.GridDefinedColums = valueField + ";" + nameField;
        configList.GridSortCondition = nameField + " ASC";
        if (attributes.dropdownCondition) {
            configList.GridFilterConditionExpression = configList.NormalizeColumName(attributes.dropdownCondition);
        }
        _DropdownConfigs[dropdownId] = configList;

        var emptyText = attributes.dropdownEmptyText;
        var emptyValue = attributes.dropdownEmptyValue;
        if (emptyText) {
            if (emptyValue == undefined) {
                emptyValue = 0;
            }
            element.append(' <option value="' + emptyValue + '"> ' + emptyText + '</option>');
        }
        element.append(' <option ng-repeat="item in Dropdowns.' + dropdownId + '" value="{{item.' + valueField + '}}" ng-bind="item.' + nameField + '"></option>');
    }
    return directive;
});

//Control for auto complete
mdlCommon.directive('autocompleteMasterTable', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {

        var autocompleteId = "autocompleteId" + parseInt(Math.random() * 1000000);
        element.attr("autocomplete-id", autocompleteId);
        element.after('<span ng-init="InitAutoComplete(\'' + autocompleteId + '\');"></span>');

    }
    return directive;
});

mdlCommon.directive('datePicker', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        var datepickerId = "datepicker" + parseInt(Math.random() * 1000000);
        element.attr("date-picker-id", datepickerId);
        element.after('<span ng-init="InitDatePicker(\'' + datepickerId + '\');"></span>');
    }
    return directive;
});

mdlCommon.directive('datePickerFor', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        var datepickerId = "datepicker" + parseInt(Math.random() * 1000000);
        element.attr("date-picker-id", datepickerId);
        element.after('<span ng-init="InitDatePickerFor(\'' + datepickerId + '\',\'' + attributes.datePickerFor + '\');"></span>');
    }
    return directive;
});

mdlCommon.directive('dateRangeFilterFor', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        var gridId = attributes.dateRangeFilterFor;
        element.html(
        ' <input type="text" class="form-control input-sm width-20" readonly date-picker-for="' + gridId + '" ng-model="FilterRangeDate.StartDate"'
        + 'placeholder="Từ ngày" >'//ng-change="ChangeFilterRangeDate(\'' + gridId + '\')"
        + ' <input type="text" class="form-control input-sm width-20" readonly date-picker-for="' + gridId + '" ng-model="FilterRangeDate.EndDate"'
        + 'placeholder="Đến ngày" >'//ng-change="ChangeFilterRangeDate(\'' + gridId + '\')"
        + ' <button type="button" class="btn btn-sm btn-outline" ng-class="{1:\'clicked\'}[RangeDateCode]" ng-click="SetFilterRangeDate(1, \'' + gridId + '\')">Tuần</button>'
        + ' <button type="button" class="btn btn-sm btn-outline" ng-class="{2:\'clicked\'}[RangeDateCode]" ng-click="SetFilterRangeDate(2, \'' + gridId + '\')">Tháng</button>'
        + ' <button type="button" class="btn btn-sm btn-outline" ng-class="{3:\'clicked\'}[RangeDateCode]" ng-click="SetFilterRangeDate(3, \'' + gridId + '\')">Quí</button>'
        + ' <button type="button" class="btn btn-sm btn-outline" ng-class="{4:\'clicked\', 5:\'clicked\', 6:\'clicked\'}[RangeDateCode]" data-toggle="dropdown" style="padding: 5px 3px"><i class="fa fa-caret-down"></i></button>'
        + ' <ul class="dropdown-menu dropdown-menu-right" role="menu">'
        + ' <li><a href="#" ng-click="SetFilterRangeDate(4, \'' + gridId + '\')">Tuần trước</a></li>'
        + ' <li><a href="#" ng-click="SetFilterRangeDate(5, \'' + gridId + '\')">Tháng trước</a></li>'
        + ' <li><a href="#" ng-click="SetFilterRangeDate(6, \'' + gridId + '\')">Quí trước</a></li>'
        + ' </ul>'
        );
        if (attributes.dateRangeInitCode) {
            element.append("<span ng-init=\"SetFilterRangeDate(" + attributes.dateRangeInitCode + ",'')\"></span>");
        }
    }
    return directive;
});

mdlCommon.controller('ctrlPaging', ['$scope', '$interpolate', function ($scope, $interpolate) {
    //Global variable
    $scope.CurrentUser = g_currentUserId;
    $scope.CurrentStore = g_currentStoreId;
    $scope.CurrentProductGroup = g_currentStoreProductGroup;
    $scope.RULES = g_Rules;

    /*begin configurable*/
    //Number of displayed index in the paging. It should be odd number
    $scope.NumDisplayedIndex = 7;
    //List number which user can choose	
    $scope.ListNumOfItem = [5, 10, 20, 50, 100];
    //private value, it's used to generate multi grid 

    /*end configurable*/

    /*begin user's input*/
    //Number of record on one Page
    $scope.Config = window._GridConfigData;
    $scope.ConfigDropdown = window._DropdownConfigs;
    /*end user's input*/

    /*begin dataset*/
    $scope.DataSet = {};
    for (var i = 0; i < window._ListGridIds.length ; i++) {
        $scope.DataSet[window._ListGridIds[i]] = new GridViewDataSet();
    }

    /*config for drop down*/
    $scope.Dropdowns = {};

    /*begin temp para*/
    //Number of page
    $scope.GetNumOfPage = function (gridId) {
        this.Config[gridId].NumOfPage = Math.ceil(this.DataSet[gridId].TotalItems / this.Config[gridId].NumOfItemOnPage);
    }

    //Get first index is shown
    $scope.GetStartIndex = function (gridId) {
        this.Config[gridId].StartIndex = this.Config[gridId].CurrentPage - Math.floor(this.NumDisplayedIndex / 2);
        var endShowIndex = this.Config[gridId].CurrentPage + Math.floor(this.NumDisplayedIndex / 2);
        if (endShowIndex > this.Config[gridId].NumOfPage) {
            this.Config[gridId].StartIndex -= (endShowIndex - this.Config[gridId].NumOfPage);
        }
        if (this.Config[gridId].StartIndex <= 0) {
            this.Config[gridId].StartIndex = 1;
        }
    }

    //Get last index is shown
    $scope.GetEndIndex = function (gridId) {
        var startShowIndex = this.Config[gridId].CurrentPage - Math.floor(this.NumDisplayedIndex / 2);
        this.Config[gridId].EndIndex = this.Config[gridId].CurrentPage + Math.floor(this.NumDisplayedIndex / 2);
        if (startShowIndex <= 0) {
            this.Config[gridId].EndIndex += 1 - startShowIndex;
        }
        if (this.Config[gridId].EndIndex > this.Config[gridId].NumOfPage) {
            this.Config[gridId].EndIndex = this.Config[gridId].NumOfPage;
        }
    }

    $scope.GetListPageIndex = function (gridId) {
        while (this.Config[gridId].ListPageIndex.length > 0) {
            this.Config[gridId].ListPageIndex.pop();
        }
        for (var i = this.Config[gridId].StartIndex; i <= this.Config[gridId].EndIndex; i++) {
            this.Config[gridId].ListPageIndex.push(i);
        }
    }

    $scope.CalculatedGridPara = function (gridId) {
        if ($scope.DataSet[gridId] == undefined) return;

        $scope.DataSet[gridId].TotalItems = $scope.GetNumTotalRecords(gridId);

        $scope.GetNumOfPage(gridId);
        $scope.GetStartIndex(gridId);
        $scope.GetEndIndex(gridId);
        $scope.GetListPageIndex(gridId);
        if ($scope.Config[gridId].CurrentPage > $scope.Config[gridId].EndIndex) {
            //fix issue: load empty data
            $scope.Config[gridId].CurrentPage = ($scope.Config[gridId].EndIndex != 0 ? $scope.Config[gridId].EndIndex : 1);
        }
        else if ($scope.Config[gridId].CurrentPage < 1) {
            $scope.Config[gridId].CurrentPage = 1;
        }

        $scope.Config[gridId].StartRow = ($scope.Config[gridId].CurrentPage - 1) * $scope.Config[gridId].NumOfItemOnPage + 1;
        $scope.Config[gridId].EndRow = $scope.Config[gridId].CurrentPage * $scope.Config[gridId].NumOfItemOnPage;


        //Get Data from DB
        //Evaluate condition before send to execute in DB
        var config = $scope.Config[gridId];
        config.EvaluateFieldExpression($interpolate, $scope);
        //getDataListUrl is defined in global
        $scope.DataSet[gridId].Data = config.GetListData();

        //config.GetListDataAsync(function (result) {
        //    $scope.$applyAsync(function () {
        //        $scope.DataSet[gridId].Data = result;
        //    });
        //});

        //Sum Data from DB
        $scope.DataSet[gridId].Sums = config.SumListData();

    }
    /*end temp para*/

    //index is base-1
    $scope.GridChangePageIndex = function (index, gridId) {
        if (this.Config[gridId].CurrentPage != index) {
            this.Config[gridId].CurrentPage = index;
            this.CalculatedGridPara(gridId);
        }
    }

    $scope.GridChangeNumRowsOnPage = function (gridId) {
        this.CalculatedGridPara(gridId);
    };

    $scope.GridFilter = function (gridId) {
        this.CalculatedGridPara(gridId);
    };

    $scope.GridSortBy = function (sortBy, gridId) {
        if (this.Config[gridId].OrderBy == sortBy) {
            this.Config[gridId].OrderDirection = -this.Config[gridId].OrderDirection;
        }
        else {
            this.Config[gridId].OrderBy = sortBy;
            this.Config[gridId].OrderDirection = 1;
        }
        this.CalculatedGridPara(gridId);
    };

    $scope.GetNumTotalRecords = function (gridId) {
        //Evaluate condition before send to execute in DB
        var config = $scope.Config[gridId];
        config.EvaluateFieldExpression($interpolate, $scope);
        //countDataListUrl is defined in global
        var result = config.CountListData();
        if (!result) result = 0;
        return result;
    }

    /*$scope.SumListDataFromDB = function (gridId) {
        //Evaluate condition before send to execute in DB
        var config = $scope.Config[gridId];
        config.EvaluateFieldExpression($interpolate, $scope);
        //getDataListUrl is defined in global
        return config.SumListData();
    }*/

    $scope.ExportExcel = function (gridId, template) {
        //Evaluate condition before send to execute in DB
        var config = $scope.Config[gridId];
        config.ExportDataToExcel(template, {});
    }

    $scope.ExportExcelObject = function (gridId, template, object) {
        //Evaluate condition before send to execute in DB
        var config = $scope.Config[gridId];
        config.ExportDataToExcel(template, object);
    }


    $scope.ReloadGrid = function (gridId) {
        $scope.CalculatedGridPara(gridId);
    }

    $scope.ReloadDropdown = function (dropdownId) {
        //Evaluate condition before send to execute in DB
        var config = $scope.ConfigDropdown[dropdownId];
        if (config) {
            config.EvaluateFieldExpression($interpolate, $scope);
            //getDataListUrl is defined in global
            //$scope.Dropdowns[dropdownId] = config.GetListData();

            config.GetListDataAsync(function (result) {
                $scope.$applyAsync(function () {
                    $scope.Dropdowns[dropdownId] = result;
                });
            });
        }
    }

    $scope.InitVisibleGrid = function (gridId) {
        //if ($('table[grid-data="' + gridId + '"]').is(":visible")) {
        $scope.ReloadGrid(gridId);
        //}
    }

    $scope.InitVisibleDropdown = function (dropdownId) {
        //if ($('select[dropdown-id="' + dropdownId + '"]').is(":visible")) {
        if (!this.Dropdowns[dropdownId]) {
            //alert('dropdown ' + dropdownId);
            $scope.ReloadDropdown(dropdownId);
        }
    }

    $scope.ReloadMasterDrodowns = function (tableName) {
        for (var key in this.ConfigDropdown) {
            if (this.ConfigDropdown[key].GridDataObject == tableName) {
                $scope.ReloadDropdown(key);
            }
        }
    }

    $scope.ReloadAllVisibleControls = function () {
        $('table[grid-data]:visible').each(function () {
            var gridId = $(this).attr('grid-data');
            if ($scope.DataSet[gridId] != undefined) {
                $scope.ReloadGrid(gridId);
            }
        });
    }

    $scope.FilterRangeDate = {
        StartDate: "",
        EndDate: ""
    };
    $scope.RangeDateCode = 0;
    $scope.ChangeFilterRangeDate = function (gridId) {
        if ($scope.FilterRangeDate.StartDate && $scope.FilterRangeDate.EndDate) {
            $scope.ReloadGrid(gridId);
        }
    }
    $scope.SetFilterRangeDate = function (option, gridId) {

        var curr = new Date(); // get current date
        var first = curr.getDate() - curr.getDay() + 1; // First day is the day of the month - the day of the week
        var last = first + 6; // last day is the first day + 6
        var y = curr.getFullYear(), m = curr.getMonth();
        var quarter = Math.floor(curr.getMonth() / 3);

        switch (option) {
            case 0: //today
                $scope.FilterRangeDate.StartDate = formatDate(curr);
                $scope.FilterRangeDate.EndDate = formatDate(curr);
                break;
            case 1: //This week
                $scope.FilterRangeDate.StartDate = formatDate(new Date(curr.setDate(first)));
                $scope.FilterRangeDate.EndDate = formatDate(new Date(curr.setDate(last)));
                break;
            case 2: //This month
                $scope.FilterRangeDate.StartDate = formatDate(new Date(y, m, 1));
                $scope.FilterRangeDate.EndDate = formatDate(new Date(y, m + 1, 0));
                break;
            case 3: //This quarter
                $scope.FilterRangeDate.StartDate = formatDate(new Date(y, quarter * 3, 1));
                $scope.FilterRangeDate.EndDate = formatDate(new Date(y, quarter * 3 + 3, 0));
                break;
            case 4: //last week
                var firstLastWeek = new Date(curr.setDate(first - 7));
                $scope.FilterRangeDate.StartDate = formatDate(firstLastWeek);
                $scope.FilterRangeDate.EndDate = formatDate(new Date(firstLastWeek.setDate(firstLastWeek.getDate() + 6)));
                break;
            case 5: //Last month
                $scope.FilterRangeDate.StartDate = formatDate(new Date(y, m - 1, 1));
                $scope.FilterRangeDate.EndDate = formatDate(new Date(y, m, 0));
                break;
            case 6: //Last quarter
                $scope.FilterRangeDate.StartDate = formatDate(new Date(y, (quarter - 1) * 3, 1));
                $scope.FilterRangeDate.EndDate = formatDate(new Date(y, quarter * 3, 0));
                break;
        }
        $scope.RangeDateCode = option;

        $("input[date-picker-for][ng-model='FilterRangeDate.StartDate']").val($scope.FilterRangeDate.StartDate);
        $("input[date-picker-for][ng-model='FilterRangeDate.EndDate']").val($scope.FilterRangeDate.EndDate);

        //$("input[date-picker-for][ng-model='FilterRangeDate.EndDate']")
        //.datepicker("setDate", $scope.FilterRangeDate.EndDate);
        $scope.ReloadGrid(gridId);
    }

    $scope.InitAutoComplete = function (autocompleteId) {
        var element = $('input[autocomplete-id="' + autocompleteId + '"]');
        element.autocomplete({
            minLength: 0,
            source: function (request, response) {
                var configList = new GridViewConfig("");
                configList.GridDataAction = "get10";
                configList.GridDataObject = element.attr("autocomplete-master-table");
                configList.GridDefinedColums = element.attr("autocomplete-colum-id") + ";" + element.attr("autocomplete-colum-name");
                configList.GridFilterCondition = element.attr("autocomplete-colum-name") + " like N''%" + request.term + "%''";
                if (element.attr("autocomplete-colum-code")) {
                    configList.GridDefinedColums += ";" + element.attr("autocomplete-colum-code");
                    configList.GridSortCondition = element.attr("autocomplete-colum-code") + " ASC";
                    configList.GridFilterCondition += " or " + element.attr("autocomplete-colum-code") + " like N''%" + request.term + "%''";
                }
                else {
                    configList.GridSortCondition = element.attr("autocomplete-colum-name") + " ASC";
                }
                if (element.attr("autocomplete-condition")) {
                    configList.GridFilterCondition = element.attr("autocomplete-condition") + " and (" + configList.GridFilterCondition + ")";
                }
                if (element.attr("autocomplete-colum-additional")) {
                    configList.GridDefinedColums += ";" + element.attr("autocomplete-colum-additional");
                }

                var listData = configList.GetListData();
                if (listData.length > 0) {
                    response(listData);
                }
                else {
                    response(["Không tìm thấy kết quả"]);
                }
            },
            focus: function (event, ui) {
                if (ui.item[element.attr("autocomplete-colum-id")]) {
                    $(element).val(ui.item[element.attr("autocomplete-colum-name")]);
                    $(element.attr("autocomplete-model-id")).val(ui.item[element.attr("autocomplete-colum-id")]).change();
                    if (element.attr("autocomplete-model-additional")) {
                        $(element.attr("autocomplete-model-additional")).val(ui.item[element.attr("autocomplete-colum-additional")]).change();
                    }
                }
                return false;
            },
            select: function (event, ui) {
                if (ui.item[element.attr("autocomplete-colum-id")]) {
                    $(element).val(ui.item[element.attr("autocomplete-colum-name")]);
                    $(element.attr("autocomplete-model-id")).val(ui.item[element.attr("autocomplete-colum-id")]).change();
                    if (element.attr("autocomplete-model-additional")) {
                        $(element.attr("autocomplete-model-additional")).val(ui.item[element.attr("autocomplete-colum-additional")]).change();
                    }
                }
                return false;
            }
        })
        .autocomplete("instance")._renderItem = function (ul, item) {
            var content;
            if (item[element.attr("autocomplete-colum-code")]) {
                content = "<a> <b>" + item[element.attr("autocomplete-colum-code")] + " </b><br>" + item[element.attr("autocomplete-colum-name")] + "</a>";
            }
            else if (item[element.attr("autocomplete-colum-name")]) {
                content = "<a>" + item[element.attr("autocomplete-colum-name")] + "</a>";
            }
            else {
                content = "<a>" + item.label + "</a>";
            }

            return $("<li>")
                    .append(content)
                    .appendTo(ul);
        };
    }

    $scope.InitDatePicker = function (datepickerId) {
        $('input[date-picker-id="' + datepickerId + '"]').datepicker({ format: 'dd-mm-yyyy', autoclose: true/*, startDate: '23-03-2016'*/ });
    }

    $scope.InitDatePickerFor = function (datepickerId, gridId) {
        $('input[date-picker-id="' + datepickerId + '"]').datepicker({ format: 'dd-mm-yyyy', autoclose: true/*, startDate: '23-03-2016'*/ })
        .on('hide', function (e) {
            var scope = angular.element($(this).parents("[ng-controller]")[0]).scope();
            scope.$apply(function () {
                scope.ReloadGrid(gridId);
            })
        });
    }
}]);



//Use to show Dialog, can't change controller's name
/*mdlCommon.controller('ModalController', ['$scope', 'close', function ($scope, close) {
    $scope.close = function (result) {
        close(result, 0); // close, but give 500ms for bootstrap to animate
    };
}]);*/




