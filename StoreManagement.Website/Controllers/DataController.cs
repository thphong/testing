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

        [HttpPost]
        public ActionResult GetDataList(GridViewConfig gridConfig)
        {
            try
            {
                var list = dataService.GetDataFromConfigurationJsonable(SessionCollection.CurrentUserId, gridConfig);
                return Json(list);
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        [HttpPost]
        public ActionResult CountDataList(GridViewConfig gridConfig)
        {
            try
            {
                int result = dataService.CountDataFromConfiguration(SessionCollection.CurrentUserId, gridConfig);
                return Json(result);
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        [HttpPost]
        public ActionResult SumDataList(GridViewConfig gridConfig)
        {
            try
            {
                var result = dataService.SumDataFromConfiguration(SessionCollection.CurrentUserId, gridConfig);
                return Json(result);
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        [HttpPost]
        public ActionResult SaveObject(string tableName, string data)
        {
            try
            {
                int id = dataService.SaveObject(SessionCollection.CurrentUserId, tableName, data);
                return Json(id);
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        [HttpPost]
        public ActionResult SaveListObject(string tableName, string data)
        {
            try
            {
                dataService.SaveListObject(SessionCollection.CurrentUserId, tableName, data);
                return Json(true);
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        [HttpPost]
        public ActionResult GetObject(string tableName, string columName, string columValue)
        {
            try
            {
                var obj = dataService.GetObject(SessionCollection.CurrentUserId, tableName, columName, columValue);
                return Json(obj);
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        [HttpPost]
        public ActionResult SetStoreId(int storedId)
        {
            try
            {
                SessionCollection.CurrentStore = storedId;
                return Json(true);
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        [HttpPost]
        public ActionResult DeleteObject(string tableName, int keyValue, bool isHardDelete = false)
        {
            try
            {
                dataService.DeleteObject(SessionCollection.CurrentUserId, tableName, keyValue, isHardDelete);
                return Json(true);
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        public ActionResult ExportExcelAjax(GridViewConfig gridConfig)
        {
            try
            {
                gridConfig.GridDataAction = "getall";
                SessionCollection.ExportConfig = gridConfig;
                return Json(true);
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        public ActionResult ExportExcel()
        {
            DataTable data = dataService.GetDataFromConfiguration(SessionCollection.CurrentUserId, SessionCollection.ExportConfig);
            return File(Common.Export.ExportExcel.ExportToCSVFileOpenXML(data), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", SessionCollection.ExportConfig.GridId + ".xlsx");
        }

    }
}
