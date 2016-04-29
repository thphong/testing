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

    this.CountListDataAsync = function (delegate) {
        AjaxAsync(g_countDataListUrl, '{ gridConfig: ' + JSON.stringify(this) + '}', delegate);
    }

    this.GetListData = function () {
        return AjaxSync(g_getDataListUrl, '{ gridConfig: ' + JSON.stringify(this) + '}');
    }

    this.GetListDataAsync = function (delegate) {
        AjaxAsync(g_getDataListUrl, '{ gridConfig: ' + JSON.stringify(this) + '}', delegate);
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
function ObjectDataConfig(tableName, $scope) {

    this.TableName = tableName;
    this.ObjectData = {};
    this.ListObjectData = [];
    this.$scope = $scope;

    this.SetObject = function (objectData) {
        this.ObjectData = objectData;
    }

    this.SetListObject = function (listObjectData) {
        this.ListObjectData = listObjectData;
    }

    this.SaveObject = function () {
        var result = AjaxSync(g_saveObjectUrl, '{ tableName: "' + this.TableName + '", data: "' + this.GetCombinedData(this.ObjectData) + '"}');

        this.ReloadMasterData(this.TableName);

        return result;
    }


    this.SaveListObject = function () {
        var data = "";
        for (var i = 0; i < this.ListObjectData.length; i++) {
            if (data) {
                data += "<<>>";
            }
            data += this.GetCombinedData(this.ListObjectData[i]);
        }
        var result = AjaxSync(g_saveListObjectUrl, '{ tableName: "' + this.TableName + '", data: "' + data + '"}');
        return result;
    }

    //If colum is null, it will get primary key
    this.GetObject = function (columValue, columName) {
        if (columName == undefined) columName = "";
        return AjaxSync(g_getObjectUrl, '{ tableName: "' + this.TableName + '", columName : "' + columName + '", columValue: "' + columValue + '"}');
    }

    //If colum is null, it will get primary key
    this.DeleteObject = function (keyValue) {
        var result = AjaxSync(g_deleteObjectUrl, '{ tableName: "' + this.TableName + '", keyValue: ' + keyValue + '}');

        this.ReloadMasterData(this.TableName);

        return result;
    }

    //If colum is null, it will get primary key
    this.HardDeleteObject = function (keyValue) {
        var result = AjaxSync(g_deleteObjectUrl, '{ tableName: "' + this.TableName + '", keyValue: ' + keyValue + ', isHardDelete: true}');

        this.ReloadMasterData(this.TableName);

        return result;
    }

    this.RemoveSpecialChars = function (str) {
        if (str == null || str == undefined) return "";
        str = String(str);
        while (str.indexOf("::") >= 0) {
            str = str.replace(/::/g, ':');
        }
        while (str.indexOf(",,") >= 0) {
            str = str.replace(/,,/g, ',');
        }
        while (str.indexOf("<<>>") >= 0) {
            str = str.replace(/<<>>/g, '');
        }
        return str;
    }

    this.GetCombinedData = function (object) {

        var result = "";

        for (var key in object) {
            var value = object[key];
            if (result) {
                result += ",,";
            }
            result += this.RemoveSpecialChars(key) + "::" + this.RemoveSpecialChars(value);
        }

        return result;
    }

    this.CopyFields = function (fromObject, toObject) {
        for (var key in fromObject) {
            var value = fromObject[key];
            if (toObject[key] != undefined) {
                if (value != null && value != undefined) {
                    toObject[key] = value;
                }
                else {
                    toObject[key] = "";
                }
            }
        }
    }

    this.ReloadMasterData = function (tableName) {
        this.$scope.ReloadMasterDrodowns(tableName);
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
