var _CurrentGridId = "";
var _ListGridIds = [];
var _GridConfigData = {};


//Control for Gridview

mdlCommon.directive('gridPagingFor', function () {
    var directive = {};
    directive.restrict = 'A';
    directive.compile = function (element, attributes) {
        var gridId = attributes.gridPagingFor;
        element.append('<div ng-init="CalculatedGridPara(\'' + gridId + '\');"></div>'
            + '<ul class="pagination" ng-if="DataSet.' + gridId + '.TotalItems > 0" style="margin-top: 0px">'
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
        element.append('<button class="btn btn-success btn-primary" ng-click="ExportExcel(\'' + gridId + '\')">'
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

mdlCommon.directive('checkCurrency', ['$filter', function($filter) {
    return function (scope, element, attrs) {
        element.bind("change", function (event) {
            var value = $(this).val().replace(/,/g, '');            
            value = $filter('currency')(value, "", 0);
            if (value) {
                $(this).val(value);
            }
            else {
                $(this).val(0);
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
        var configList = new GridViewConfig("");
        var valueField = attributes.dropdownValueField;
        var nameField = attributes.dropdownNameField;
        configList.GridDataAction = "getall";
        configList.GridDataObject = attributes.dropdownMasterTable;
        configList.GridDefinedColums = valueField + ";" + nameField;
        configList.GridSortCondition = nameField + " ASC";

        var emptyText = attributes.dropdownEmptyText;
        var emptyValue = attributes.dropdownEmptyValue;
        if (emptyText) {
            if (emptyValue == undefined) {
                emptyValue = 0;
            }
            element.append(' <option value="' + emptyValue + '"> ' + emptyText + '</option>');
        }
        var listData = configList.GetListData();
        for (var i = 0 ; i < listData.length ; i++) {
            element.append(' <option value="' + listData[i][valueField] + '"> ' + listData[i][nameField] + '</option>');
        }
    }
    return directive;
});

mdlCommon.controller('ctrlPaging', ['$scope', '$interpolate', function ($scope, $interpolate) {
    //Global variable
    $scope.CurrentUser = g_currentUserId;

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
    /*end user's input*/

    /*begin dataset*/
    $scope.DataSet = {};
    for (var i = 0; i < window._ListGridIds.length ; i++) {
        $scope.DataSet[window._ListGridIds[i]] = new GridViewDataSet();
    }

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

        this.DataSet[gridId].TotalItems = this.GetNumTotalRecords(gridId);

        this.GetNumOfPage(gridId);
        this.GetStartIndex(gridId);
        this.GetEndIndex(gridId);
        this.GetListPageIndex(gridId);
        if (this.Config[gridId].CurrentPage > this.Config[gridId].EndIndex) {
            //fix issue: load empty data
            this.Config[gridId].CurrentPage = (this.Config[gridId].EndIndex != 0 ? this.Config[gridId].EndIndex : 1);
        }
        else if (this.Config[gridId].CurrentPage < 1) {
            this.Config[gridId].CurrentPage = 1;
        }

        this.Config[gridId].StartRow = (this.Config[gridId].CurrentPage - 1) * this.Config[gridId].NumOfItemOnPage + 1;
        this.Config[gridId].EndRow = this.Config[gridId].CurrentPage * this.Config[gridId].NumOfItemOnPage;


        //Get Data from DB
        this.DataSet[gridId].Data = this.GetListDataFromDB(gridId);
        
        //Sum Data from DB
        this.DataSet[gridId].Sums = this.SumListDataFromDB(gridId);
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

    $scope.GetListDataFromDB = function (gridId) {
        //Evaluate condition before send to execute in DB
        var config = $scope.Config[gridId];
        config.EvaluateFieldExpression($interpolate, $scope);
        //getDataListUrl is defined in global
        return config.GetListData();
    }

    $scope.SumListDataFromDB = function (gridId) {
        //Evaluate condition before send to execute in DB
        var config = $scope.Config[gridId];
        config.EvaluateFieldExpression($interpolate, $scope);
        //getDataListUrl is defined in global
        return config.SumListData();
    }

    $scope.ExportExcel = function (gridId) {
        //Evaluate condition before send to execute in DB
        var config = $scope.Config[gridId];
        config.ExportDataToExcel();
    }

    
    $scope.ReloadGrid = function (gridId) {
        this.CalculatedGridPara(gridId);
    }

}]);



//Use to show Dialog, can't change controller's name
/*mdlCommon.controller('ModalController', ['$scope', 'close', function ($scope, close) {
    $scope.close = function (result) {
        close(result, 0); // close, but give 500ms for bootstrap to animate
    };
}]);*/


mdlCommon.controller('ctrlApplyAngular', ['$scope', '$controller', function ($scope, $controller) {
    $controller('ctrlPaging', { $scope: $scope }); //This works

    //List order by
    $scope.Config[gridId].OrderBy = "value1";

    //Implement for paging
    $scope.GetNumTotalRecords = function (gridId) {
        alert("The function GetNumTotalRecords is not implemented");
    }

    $scope.GetListDataFromDB = function (gridId) {
        //$("#BodyContent").showLoading();
        alert("The function GetListDataFromDB is not implemented");
        //$("#BodyContent").hideLoading();
    }
}]);



