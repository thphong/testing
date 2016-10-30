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
using Newtonsoft.Json;

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
        public ActionResult SaveComplexObject(string tableName, string data, string subObject, string listData, string associatedColumn = "")
        {
            try
            {
                int id = dataService.SaveComplexObject(SessionCollection.CurrentUserId, tableName, data, subObject, listData, associatedColumn);
                return Json(id);
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

                var store = dataService.GetObject(SessionCollection.CurrentUserId, "T_Master_Stores", "", storedId.ToString());
                SessionCollection.StoreName = store["StoreName"].ToString();
                SessionCollection.StorePhone = store["PhoneNumber"].ToString();
                SessionCollection.StoreAddress = store["Address"].ToString();

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

        [HttpPost]
        public ActionResult CheckField(string field)
        {
            try
            {
                return Json(dataService.CheckField(SessionCollection.CurrentUserId, field));
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
        public ActionResult ImportExcelFile(string template)
        {
            try
            {
                if (Request.Files.Count > 0)
                {
                    //upload 
                    JsonResult result = (JsonResult)UploadFile(1);
                    
                    if (result.Data is string) return result;
                    //==============================
                    dynamic json = result.Data;
                    int id = json.id;
                    string filename = json.filename;
                    if (id == 0) throw new Exception("Không thể lưu file");
                    
                    //==============================
                    //read file excel
                    string filepath = Server.MapPath(filename);
                    DataTable tbl =  ExcelHelper.LoadData(filepath);
                    if (tbl == null || tbl.Rows.Count==0 ||tbl.Columns.Count==0) throw new Exception("Không thể đọc file");

                    //==============================
                    //read template info
                    var folderName = ConfigurationManager.AppSettings["ImportedTemplatePath"];
                    string confpath = Server.MapPath(folderName + template + ".conf");
                    string confcontent = FileHelper.ReadFile(confpath);
                    dynamic templateinfo = JsonConvert.DeserializeObject(confcontent);

                    //==============================
                    //kiểm tra va lấy dữ liệu
                    bool hasError = false;
                    DataTable convertedTable = new DataTable();
                    DataTable errorTable = new DataTable();
                    List<string> columnNames = new List<string>();
                    List<string> columnCodes = new List<string>();
                    #region convert datatble
                    for (int c = 0; c < templateinfo.Codes.Count; c++)
                    {
                        string code = templateinfo.Codes[c].ToString();
                        string name = templateinfo.Names[c].ToString();

                        DataColumn col = new DataColumn(code);
                        convertedTable.Columns.Add(col);

                        col = new DataColumn(code);
                        errorTable.Columns.Add(col);

                        columnCodes.Add(code);
                        columnNames.Add(name);
                    }
                    
                    //kiểm tra từng dòng dữ liệu
                    for (int r = 0; r < tbl.Rows.Count; r++)
                    {
                        DataRow oldrow = tbl.Rows[r];
                        DataRow newrow = convertedTable.NewRow();
                        DataRow errrow = errorTable.NewRow();
                        for (int c = 0; c < templateinfo.Codes.Count; c++)
                        {
                            var code = templateinfo.Codes[c].ToString();
                            var name = templateinfo.Names[c].ToString();
                            var valid = templateinfo.Valids[c];

                            string err = ""; //không có lỗi
                            string value = "";
                            //kiểm tra có chứa name hay không
                            if (tbl.Columns.Contains(name))
                            {
                                try
                                {
                                    value = oldrow[name].ToString();
                                }
                                catch(Exception exX)
                                {
                                }
                            }
                            
                            //===========================
                            if (string.IsNullOrEmpty(value))
                            {
                                if (Convert.ToBoolean(valid.IsNotEmpty))
                                {
                                    err = "Không có dữ liệu";
                                }

                                try
                                {
                                    if (valid.DefaultValue!=null)
                                    {
                                        value = valid.DefaultValue.ToString();
                                    }
                                }
                                catch { }
                            }
                            else if (Convert.ToBoolean(valid.IsInList))
                            {
                                List<dynamic> list = valid.InList.ToObject<List<dynamic>>();
                                var stringList = list.ConvertAll<string>(o => o.ToString());
                                string find =stringList.Find(s => s.CompareTo(value)==0);
                                if (string.IsNullOrEmpty(find))
                                {
                                    err = "Giá trị không hợp lệ. Giá trị phải là : " + string.Join(",", list);
                                }
                            }

                            if (!string.IsNullOrEmpty(err)) hasError = true;
                            //============================
                            newrow[code] = value;
                            errrow[code] = err;


                        }

                        convertedTable.Rows.Add(newrow);
                        errorTable.Rows.Add(errrow);
                    }
                    #endregion

                    //==============================
                    //nếu có lỗi thì trả về kết quả lỗi
                    var datatable = JsonHelper.DataTable2Json(convertedTable);
                    var errtable = JsonHelper.DataTable2Json(errorTable);
                    if (hasError)
                    {
                        return Json(new { isError = true, columnNames = columnNames, columnCodes = columnCodes, dataTable = datatable, errorTable = errtable });
                    }
                    //==============================
                    //ok thì lưu kết quả
                    //dataService.SaveListObject(SessionCollection.CurrentUserId, "", "");
                }

                return Json(new { isError = false });
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        [HttpPost]
        public ActionResult UploadFile(int fileType,string fileName ="")
        {
            try
            {
                if (Request.Files.Count > 0)
                {
                    //~/Resource/ProductImage/
                    var file = Request.Files[0];
                    var folderName = ConfigurationManager.AppSettings["UploadFilePath"] + "/FileType" + fileType + "/" + DateTime.Today.Year + "/" + DateTime.Today.Month;

                    if (!Directory.Exists(Server.MapPath(folderName)))
                        Directory.CreateDirectory(Server.MapPath(folderName));

                    var name_only = Path.GetFileNameWithoutExtension(file.FileName);
                    if (!string.IsNullOrEmpty(fileName))
                    {
                        name_only = fileName; //lấy tên file mà ngưởi dùng đặt
                    }
                    var ext = Path.GetExtension(file.FileName); //ext has .
                    //var file_name = string.Format("{0}_{1}.{2}", name_only, Guid.NewGuid(), ext);

                    var file_name = folderName + "/" + DateTime.Now.ToString("hhmmss") + "_" + name_only  + ext;
                    string path = Server.MapPath(file_name);

                    file.SaveAs(path);

                    //Save url in object
                    int id = dataService.SaveObject(SessionCollection.CurrentUserId, "T_Master_File",
                        string.Format("{0}::{1},,{2}::{3},,{4}::{5},,StoreId::{6},,IsActive::1,,Version::-1",
                        "FileName", name_only + ext, "FilePath", file_name, "FileTypeId", fileType,SessionCollection.CurrentStore));

                    return Json(new {id = id, filename = file_name});
                }

                return Json(new { id = 0, filename = "" });
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        public ActionResult DownloadExcelTemplate(string template)
        {
            string filepath = Server.MapPath(ConfigurationManager.AppSettings["ImportedTemplatePath"] + template +".xlsx");
            return File(filepath, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                , template + ".xlsx");
        }

        public ActionResult DownloadFile(int fileid)
        {
            try
            {
                var obj = dataService.GetObject(SessionCollection.CurrentUserId, "T_Master_File", "FileId", fileid.ToString());
                string name = obj["FileName"].ToString(); ;
                string filename = obj["FilePath"].ToString(); 
                string ext = Path.GetExtension(filename);
                string contentType = FileHelper.GetMimeType(ext);
                string filepath = Server.MapPath(filename);
                return File(filepath, contentType,name);
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        [HttpPost]
        public ActionResult SaveFile(string objectName, string objectId, string PKField, string fieldName)
        {
            try
            {
                if (Request.Files.Count > 0)
                {
                    //~/Resource/ProductImage/
                    var file = Request.Files[0];
                    var folderName = ConfigurationManager.AppSettings["ResourcePath"]
                        + "/" + DateTime.Today.Year + "/" + DateTime.Today.Month;

                    if (!Directory.Exists(Server.MapPath(folderName)))
                        Directory.CreateDirectory(Server.MapPath(folderName));

                    var filename = folderName + "/" + DateTime.Now.ToString("hhmmss") + objectName + "_" + fieldName + "_" + objectId
                        + Path.GetExtension(file.FileName);
                    string path = Server.MapPath(filename);

                    file.SaveAs(path);

                    //Save url in object
                    dataService.SaveObject(SessionCollection.CurrentUserId, objectName, string.Format("{0}::{1},,{2}::{3},,Version::-1", PKField, objectId, fieldName, filename));

                    return Json(filename);
                }

                return Json(true);
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        public ActionResult GetFile(string url)
        {
            try
            {
                return File(url, "image/png");
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
                var config = new GridViewConfig()
                {
                    GridDataObject = "T_System_Rule",
                    GridDefinedColums = "RuleName;Value",
                    GridDataAction = "getall",
                    GridFilterCondition = "StoreId = 0 or StoreId = " + SessionCollection.CurrentStore
                };
                return Json(dataService.GetRules(SessionCollection.CurrentUserId, config));
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        [HttpPost]
        public ActionResult ExecuteSQL(string sql)
        {
            try
            {
                if (SessionCollection.IsDeveloper)
                {
                    return Json(dataService.ExecuteSQL(SessionCollection.CurrentUserId, sql));
                }
                throw new Exception("You are not developer!");
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }
    }
}
