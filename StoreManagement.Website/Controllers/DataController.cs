using StoreManagement.Service;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using StoreManagement.Common;
using System.Configuration;
using System.IO;

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

        [HttpPost]
        public ActionResult CheckCanCreate(string tableName)
        {
            try
            {
                return Json(dataService.CheckCanCreate(SessionCollection.CurrentUserId, tableName));
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        public ActionResult ExportExcelWithTemplateAjax(string template, Dictionary<string, object> objectData, GridViewConfig gridConfig)
        {
            try
            {
                gridConfig.GridDataAction = "excel";
                SessionCollection.ExportConfig = gridConfig;
                SessionCollection.ExportObjectData = objectData;
                SessionCollection.ExportTemplate = template;
                return Json(true);
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        public ActionResult ExportExcelWithTemplate()
        {
            string template = Server.MapPath(ConfigurationManager.AppSettings["ExportedTemplatePath"] + SessionCollection.ExportTemplate);
            DataTable list = dataService.GetDataFromConfiguration(SessionCollection.CurrentUserId, SessionCollection.ExportConfig);
            return File(Common.Export.ExportExcel.ExportFromTempalte(template, SessionCollection.ExportObjectData, list), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                , SessionCollection.ExportConfig.GridId + DateTime.Now.ToString(" dd-MM-yyyy hh_mm_ss") + ".xlsx");
        }

        public ActionResult ExportExcelAjax(GridViewConfig gridConfig)
        {
            try
            {
                gridConfig.GridDataAction = "excel";
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

        [HttpPost]
        public ActionResult SaveProductImage(string productId)
        {
            try
            {
                if (Request.Files.Count > 0)
                {
                    var file = Request.Files[0];
                    string path = Server.MapPath(ConfigurationManager.AppSettings["ProductImagePath"] + productId + ".png");
                    file.SaveAs(path);
                }

                return Json(true);
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }
        
        public ActionResult GetProductImage(string productId)
        {
            try
            {
                return File(ConfigurationManager.AppSettings["ProductImagePath"] + productId + ".png", "image/png");
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        [HttpPost]
        public ActionResult GetAllRules()
        {
            try
            {
                var config = new GridViewConfig() {
                    GridDataObject = "T_System_Rule",
                    GridDefinedColums = "RuleName;Value",
                    GridDataAction = "getall"
                };
                return Json(dataService.GetRules(SessionCollection.CurrentUserId, config));
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }
    }
}
