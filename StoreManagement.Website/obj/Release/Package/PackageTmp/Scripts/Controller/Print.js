mdlCommon.controller('PrintController',
['$scope', '$filter', '$controller', '$sce',
    function ($scope, $filter, $controller, $sce) {
        //$controller('ctrlPaging', { $scope: $scope });

        $scope.Terms = {
            Data : [],
            IsInited : false
        };

        $scope.SampleData = {};
        
        $scope.TemplateFormConfig = new ObjectDataConfig("T_Master_PrintTemplates", $scope);
        $scope.PrintTemplate = "";

        $scope.GetPrintTemplate = function(templateCode)
        {
            if (!$scope.PrintTemplate) {
                $scope.PrintTemplate = $scope.TemplateFormConfig.GetObject(templateCode, "TemplateCode")["RuntimeBody"];

                for (var i = 0 ; i < $scope.Terms.Data.length; i++) {
                    var item = $scope.Terms.Data[i];
                    $scope.PrintTemplate = $scope.PrintTemplate.replace(item["Term"], item["ReplacedTerm"]);
                }

                $scope.PrintTemplate = $sce.trustAsHtml($scope.PrintTemplate);
            }
        }
        
        $scope.GetListPrintTerm = function (func)
        {
            if (!$scope.Terms.IsInited) {

                var configGrid = new GridViewConfig("");
                configGrid.GridDataAction = "getall";
                configGrid.GridDataType = "table";
                configGrid.GridDataObject = "dbo.T_Master_PrintTerms";
                configGrid.GridDefinedColums = "Term;ReplacedTerm;SampleData;Func";
                if (func) {
                    configGrid.GridFilterCondition = "[Func] = ''" + func + "'' or [Func] = ''Common''";
                }

                $scope.Terms.Data = configGrid.GetListData();

                for (var i = 0; i < $scope.Terms.Data.length; i++) {
                    var item = $scope.Terms.Data[i];
                    $scope.SampleData[item["Term"].substr(1, item["Term"].length-2)] = item["SampleData"];
                }
                if ($scope.Terms.Data.length > 0) {
                    $scope.Terms.IsInited = true;
                }
            }
        }

        $scope.PrintData = function (divId) {
            var WinPrint = window.open('', '', 'width=400,height=500');
            WinPrint.document.write($("#" + divId).html());
            WinPrint.document.close();
            WinPrint.focus();
            WinPrint.print();
            WinPrint.close();
        }

        $scope.TestPrint = function () {
            //var printContent = document.getElementById("divPrintPreview);
            var WinPrint = window.open('', '', 'width=400,height=500');
            WinPrint.document.write($("#divPrintPreview").html());
            WinPrint.document.close();
            WinPrint.focus();
            WinPrint.print();
            WinPrint.close();
        }
}]);