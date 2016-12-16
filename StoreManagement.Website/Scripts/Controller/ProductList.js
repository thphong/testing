
mdlCommon.controller('ProductListController',
['$scope', '$filter', '$controller',
    function ($scope, $filter, $controller) {
        
        $scope.InitListAutoCompleteProducts = function (elementId, includeNegative, includeNotPrice, includeCombo, includeNotCost) {
            $(elementId).autocomplete({
                minLength: 0,
                //selectFirst :true,
                source: function (request, response) {
                    var configList = new GridViewConfig("");
                    configList.GridDataAction = "get10";
                    configList.GridDataObject = "T_Trans_Products";
                    configList.GridDefinedColums = "ProductId;ProductCode;ProductName;Quantity;Cost;Price;VAT;AllowNegative;#IsSelling;#IsActive;#IsCombo";
                    configList.GridFilterCondition = "StoreId = " + $scope.CurrentStore + " and IsSelling = 1 and IsActive = 1 and (ProductCode like N''%" + request.term + "%'' or ProductName like N''%" + request.term + "%'')";
                    configList.GridSortCondition = "ProductCode ASC";

                    if (!includeNegative) {
                        configList.GridFilterCondition += " and (AllowNegative = 1 or Quantity > 0)";
                    }

                    if (!includeNotPrice) {
                        configList.GridFilterCondition += " and (Price > 0)";
                    }

                    if (!includeNotCost) {
                        configList.GridFilterCondition += " and (Cost > 0)";
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
                    //$(elementId).val(ui.item.ProductCode);
                    return false;
                },
                select: function (event, ui) {
                    if (ui.item.ProductCode) {
                        var scope = angular.element($(elementId).parents("[ng-controller]")[0]).scope();
                        scope.$apply(function () {
                            scope.SelectProduct(ui.item);
                        })
                        $(elementId).val("").change();
                        setTimeout(function () { $(".ui-menu-item").hide(); }, 200);
                        
                    }
                    return false;
                },
                open: function (event, ui) {
                    var widget = $(this).data('ui-autocomplete');
                    var menu = widget.menu
                    , i = 0
                    , $items = $('li', menu.element)
                    , item
                    , text
                    , startsWith = new RegExp("^" + this.value, "i");

                    /*
                    for (; i < $items.length && !item; i++) {
                        text = $items.eq(i).text();
                        console.log(startsWith);
                        if (startsWith.test(text)) {
                            item = $items.eq(i);
                        }
                    }
                    */
                    if ($items.length == 1)
                        item = $items.eq(i);

                    if (item) {
                        menu.focus(null, item);
                        
                    }
                }
            })
            .keyup(function (e) {
                if(e.which === 13) {
                    $(".ui-menu-item").hide();
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