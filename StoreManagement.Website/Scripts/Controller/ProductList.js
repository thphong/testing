
mdlCommon.controller('ProductListController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        
        $scope.InitListAutoCompleteProducts = function (elementId, includeNegative, includeNotPrice, includeCombo) {
            $(elementId).autocomplete({
                minLength: 0,
                source: function (request, response) {
                    var configList = new GridViewConfig("");
                    configList.GridDataAction = "get10";
                    configList.GridDataObject = "T_Trans_Products";
                    configList.GridDefinedColums = "ProductId;ProductCode;ProductName;Quantity;Cost;Price;VAT;AllowNegative;#IsSelling;#IsActive;#IsCombo";
                    configList.GridFilterCondition = "StoreId = " + g_currentStoreId + " and IsSelling = 1 and IsActive = 1 and (ProductCode like N''%" + request.term + "%'' or ProductName like N''%" + request.term + "%'')";
                    configList.GridSortCondition = "ProductCode ASC";

                    if (!includeNegative) {
                        configList.GridFilterCondition += " and (AllowNegative = 1 or Quantity > 0)";
                    }

                    if (!includeNotPrice) {
                        configList.GridFilterCondition += " and (Cost > 0 and Price > 0)";
                    }

                    if (!includeCombo) {
                        configList.GridFilterCondition += " and (IsCombo = 0)";
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
                    $(elementId).val(ui.item.ProductCode);
                    return false;
                },
                select: function (event, ui) {
                    if (ui.item.ProductCode) {
                        var scope = angular.element($(elementId).parents("[ng-controller]")[0]).scope();
                        scope.$apply(function () {
                            scope.SelectProduct(ui.item);
                        })
                        $(elementId).val("").change();
                    }
                    return false;
                }
            })
            .autocomplete("instance")._renderItem = function (ul, item) {
                var content;
                if (item.ProductCode) {
                    content = "<a> <b>" + item.ProductName + " </b><br> Mã : " + item.ProductCode + "<br> Giá : " + item.Price + " | Tồn : " + item.Quantity + " </a>";
                }
                else {
                    content = "<a>" + item.label + "</a>";
                }
                return $("<li>")
                        .append(content)
                        .appendTo(ul);
            };
        }

    }]);