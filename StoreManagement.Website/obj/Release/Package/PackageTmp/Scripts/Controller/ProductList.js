
mdlCommon.controller('ProductListController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        
        $scope.InitListAutoCompleteProducts = function (elementId, includeNegative, includeNotPrice) {
            $(elementId).autocomplete({
                minLength: 0,
                source: function (request, response) {
                    var configList = new GridViewConfig("");
                    configList.GridDataAction = "get10";
                    configList.GridDataObject = "T_Trans_Product_Store";
                    configList.GridDefinedColums = "ProductId;ProductId.ProductCode;ProductId.ProductName;Quantity;ProductId.Cost;ProductId.Price;ProductId.VAT;ProductId.AllowNegative;#ProductId.IsSelling;#ProductId.IsActive";
                    configList.GridFilterCondition = "T_Trans_Product_Store.StoreId = " + g_currentStoreId + " and ProductId.IsSelling = 1 and ProductId.IsActive = 1 and (ProductId.ProductCode like N''%" + request.term + "%'' or ProductId.ProductName like N''%" + request.term + "%'')";
                    configList.GridSortCondition = "ProductId.ProductCode ASC";

                    if (!includeNegative) {
                        configList.GridFilterCondition += " and (ProductId.AllowNegative = 1 or T_Trans_Product_Store.Quantity > 0)";
                    }

                    if (!includeNotPrice) {
                        configList.GridFilterCondition += " and (ProductId.Cost > 0 and ProductId.Price > 0)";
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