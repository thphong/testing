using StoreManagement.Service;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using StoreManagement.Common;

namespace StoreManagement.Website.Controllers
{
    public class DataController : Controller
    {
        public IDataService dataService;

        public DataController(IDataService _dataService)
        {
            dataService = _dataService;
        }

        public ActionResult Input()
        {
            //var list = dataService.GetDataFromConfiguration("DataList_001", 1, null, "get", new GridViewConfig { StartRow = 1, EndRow = 10 });
            return View();
        }

        [HttpPost]
        public ActionResult GetDataList(GridViewConfig gridConfig)
        {
            var list = dataService.GetDataFromConfigurationJsonable(SessionCollection.CurrentUserId, gridConfig);
            return Json(list);
        }

        [HttpPost]
        public ActionResult CountDataList(GridViewConfig gridConfig)
        {
            int result = dataService.CountDataFromConfiguration(SessionCollection.CurrentUserId, gridConfig);
            return Json(result);
        }

        [HttpPost]
        public ActionResult SumDataList(GridViewConfig gridConfig)
        {
            var result = dataService.SumDataFromConfiguration(SessionCollection.CurrentUserId, gridConfig);
            return Json(result);
        }

        [HttpPost]
        public ActionResult SaveObject(string tableName, string data)
        {
            dataService.SaveObject(SessionCollection.CurrentUserId, tableName, data);
            return Json(true);
        }

        [HttpPost]
        public ActionResult GetObject(string tableName, string columName, string columValue)
        {
            var obj = dataService.GetObject(SessionCollection.CurrentUserId, tableName, columName, columValue);
            return Json(obj);
        }

        [HttpPost]
        public ActionResult DeleteObject(string tableName, string columName, string columValue)
        {
            dataService.DeleteObject(SessionCollection.CurrentUserId, tableName, columName, columValue);
            return Json(true);
        }

        public ActionResult ExportExcelAjax(GridViewConfig gridConfig)
        {
            gridConfig.GridDataAction = "getall";
            SessionCollection.ExportConfig = gridConfig;
            return Json(true);
        }

        public ActionResult ExportExcel()
        {
            DataTable data = dataService.GetDataFromConfiguration(SessionCollection.CurrentUserId, SessionCollection.ExportConfig);
            return File(Common.Export.ExportExcel.ExportToCSVFileOpenXML(data), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", SessionCollection.ExportConfig.GridId + ".xlsx");
        }

    }
}
