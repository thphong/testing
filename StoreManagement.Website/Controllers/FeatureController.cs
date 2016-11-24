using StoreManagement.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Dynamic;
using StoreManagement.Common.PDF;
using System.IO;
using System.Configuration;
using StoreManagement.Common;

namespace StoreManagement.Website.Controllers
{
    public class FeatureController : Controller
    {
        public IDataService dataService;

        public FeatureController(IDataService _dataService)
        {
            dataService = _dataService;
        }

        [HttpPost]
        public ActionResult CreateProductBarcodePDF(int printSize, int itemInfo, List<ExpandoObject> list)
        {
            try
            {
                var result = string.Format(" {0} - {1} : {2}" , printSize,itemInfo, list.Count);
                var listPDFItems = new List<iPDFItem>();
                foreach(ExpandoObject obj in list){
                    var dic = ((IDictionary<string, object>)obj);
                    string code = dic["ProductCode"].ToString();//(string) obj.ProductCode;
                    string name = dic["ProductName"].ToString();
                    double price = Convert.ToDouble(dic["Price"]);
                    int quantity = Convert.ToInt32(dic["Quantity"]);

                    for (int i = 0; i < quantity; i++)
                    {
                        ProductPDFItem product = new ProductPDFItem(code, name, price);
                        listPDFItems.Add(product);
                    }
                }

                MemoryStream stream = new MemoryStream(new byte[2000]);
                string filename = "MaVach_" + Guid.NewGuid() + ".pdf";
                string path =  Server.MapPath(ConfigurationManager.AppSettings["ExportedBarcodePDF"] + filename);

                //ProductBarcodeHelper.CreatePDF(path, listPDFItems, 10, 10);
                ProductBarcodeHelper.CreateBarcode(path);

                //return File(stream, "application/pdf", filename);
                //return File(path, "application/pdf", filename);
                string url = Url.Action("DownloadPDF", "Feature") + "?filename=" + filename;
                return Json(url);
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }

        public ActionResult DownloadPDF(string filename)
        {
            string filepath = Server.MapPath(ConfigurationManager.AppSettings["ExportedBarcodePDF"] + filename);
            if (FileHelper.IsExists(filepath))
            {
                return File(filepath, "application/pdf"
                    , filename);
            }
            else
            {
                throw new Exception("" + filename + " is not found.");
            }
        }

    }
}