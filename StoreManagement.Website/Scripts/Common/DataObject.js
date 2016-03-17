//user for getting list data
function GridViewConfig(gridId) {
    this.NumOfItemOnPage = 10;
    this.NumOfPage = 0;
    this.StartIndex = 0;
    this.EndIndex = 0;
    this.CurrentPage = 1;
    this.FilterBy = "";
    this.OrderBy = "";
    this.OrderDirection = 1;
    this.StartRow = 0; //base index: 1
    this.EndRow = 1; //base index: 1
    this.ListPageIndex = [];

    //config to get data in DB
    this.GridId = gridId; //config in DB to check who can execute this script
    this.GridDataType = "table"; //table or function
    this.GridDataAction = "get"; //count, get, getall, sum
    this.GridDataObject = ""; //table name or function name
    this.GridFilterConditionExpression = "";
    this.GridFilterCondition = "";
    this.GridSortCondition = "";
    this.GridDefinedColums = "";
    this.ListDefinedColums = [];
    this.GridParametersExpression = "";
    this.GridParameters = "";
    this.GridSumColums = "";

    this.EvaluateFieldExpression = function ($interpolate, $scope) {
        this.GridFilterCondition = $interpolate(this.GridFilterConditionExpression)($scope);
        this.GridParameters = $interpolate(this.GridParametersExpression)($scope);
        return;
    }

    this.CountListData = function () {
        return AjaxSync(g_countDataListUrl, '{ gridConfig: ' + JSON.stringify(this) + '}');
    }

    this.GetListData = function () {
        return AjaxSync(g_getDataListUrl, '{ gridConfig: ' + JSON.stringify(this) + '}');
    }

    this.SumListData = function () {
        if (this.GridSumColums) {
            return AjaxSync(g_sumDataListUrl, '{ gridConfig: ' + JSON.stringify(this) + '}');
        }
        else {
            return {};
        }
    }

    this.ExportDataToExcel = function () {
        AjaxAsync(g_exportExcelAjaxUrl, '{ gridConfig: ' + JSON.stringify(this) + '}',
            function () {
                window.location = g_exportExcelUrl;
            });
    }

    this.NormalizeColumName = function (columName) {
        if (!columName) return "";
        var result = "";
        var isOpen = false;
        var fieldName = "";
        for (var i = 0 ; i < columName.length ; i++) {
            if (columName[i] == '[') {
                isOpen = true;
            }
            else if (columName[i] == ']') {
                isOpen = false;
                if (fieldName.indexOf(".") < 0) {
                    result += this.GridDataObject + ".";
                }
                result += fieldName;

                //if field name not existed, we must declare in colums
                if ($.inArray(fieldName, this.ListDefinedColums) == -1) {
                    if (this.GridDefinedColums) {
                        this.GridDefinedColums += ";";
                    }
                    this.GridDefinedColums += "#" + fieldName;
                    this.ListDefinedColums.push(fieldName);
                }

                fieldName = "";
            }
            else {
                if (isOpen) {
                    fieldName += columName[i];
                }
                else {
                    result += columName[i];
                }
            }
        }
        return result;
    }
}

//User for single object
function ObjectDataConfig(tableName) {

    this.TableName = tableName;
    this.ObjectData = {};

    this.SetObject = function (objectData) {
        this.ObjectData = objectData;
    }

    this.SaveObject = function () {
        var result = AjaxSync(g_saveObjectUrl, '{ tableName: "' + this.TableName + '", data: "' + this.GetCombinedData() + '"}');

        //reload all master dropdown
        for (var i = 0; i < _ListDropdowns.length; i++) {
            var config = _ListDropdowns[i];
            if (config.Attributes.dropdownMasterTable == this.TableName) {
                config.BindBody();
            }
        }

        return result;
    }

    //If colum is null, it will get primary key
    this.GetObject = function (columValue, columName) {
        if (columName == undefined) columName = "";
        return AjaxSync(g_getObjectUrl, '{ tableName: "' + this.TableName + '", columName : "' + columName + '", columValue: "' + columValue + '"}');
    }

    //If colum is null, it will get primary key
    this.DeleteObject = function (columValue, columName) {
        if (columName == undefined) columName = "";
        var result = AjaxSync(g_deleteObjectUrl, '{ tableName: "' + this.TableName + '", columName : "' + columName + '", columValue: "' + columValue + '"}');

        //reload all master dropdown
        for (var i = 0; i < _ListDropdowns.length; i++) {
            var config = _ListDropdowns[i];
            if (config.Attributes.dropdownMasterTable == this.TableName) {
                config.BindBody();
            }
        }

        return result;
    }

    this.RemoveSpecialChars = function (str) {
        if (!str) return "";
        str = String(str);
        while (str.indexOf("::") >= 0) {
            str = str.replace(/::/g, ':');
        }
        while (str.indexOf(",,") >= 0) {
            str = str.replace(/,,/g, ',');
        }
        return str;
    }

    this.GetCombinedData = function () {

        var result = "";

        for (var key in this.ObjectData) {
            var value = this.ObjectData[key];
            if (result) {
                result += ",,";
            }
            result += this.RemoveSpecialChars(key) + "::" + this.RemoveSpecialChars(value);
        }

        return result;
    }

    this.ConvertFieldsToString = function (fromObject, toObject) {
        for (var key in fromObject) {
            var value = fromObject[key];
            if (toObject[key] != undefined) {
                if (value != null && value != undefined) {
                    toObject[key] = String(value);
                }
                else {
                    toObject[key] = "";;
                }
            }
        }
    }
}

//Use for gridview
function GridViewDataSet() {
    this.TotalItems = 0;
    this.Data = [];
    this.Sums = {};
    this.HasRecord = function () {
        return this.TotalItems > 0;
    }
}


//Use for dropdown
function DropdownConfig(element, attributes) {
    this.Element = element;
    this.Attributes = attributes;

    var configList = new GridViewConfig("");
    var valueField = attributes.dropdownValueField;
    var nameField = attributes.dropdownNameField;
    configList.GridDataAction = "getall";
    configList.GridDataObject = attributes.dropdownMasterTable;
    configList.GridDefinedColums = valueField + ";" + nameField;
    configList.GridSortCondition = nameField + " ASC";
    if (attributes.dropdownCondition) {
        configList.GridFilterCondition = attributes.dropdownCondition;
    }

    var emptyText = attributes.dropdownEmptyText;
    var emptyValue = attributes.dropdownEmptyValue;
    if (emptyValue == undefined) {
        emptyValue = 0;
    }

    this.BindBody = function () {
        var model = this.Element.attr("ng-model");
        var condition = this.Element.attr("dropdown-condition");
        var jelement = $('select[ng-model="' + model + '"]');
        if (jelement.length == 0) {
            jelement = this.Element;            
        }
        else if (jelement.length > 1 && condition != undefined)
        {
            jelement = $('select[ng-model="' + model + '"][dropdown-condition="' + condition + '"]');
        }
        jelement.html("");
        if (emptyText) {
            jelement.append(' <option value="' + emptyValue + '"> ' + emptyText + '</option>');
        }

        var listData = configList.GetListData();
        for (var i = 0 ; i < listData.length ; i++) {
            jelement.append(' <option value="' + listData[i][valueField] + '"> ' + listData[i][nameField] + '</option>');
        }
    }
}