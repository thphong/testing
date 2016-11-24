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
                int rows = 5, cols = 5;
                iTextSharp.text.Rectangle rect = iTextSharp.text.PageSize.A4;
                #region get page info
                switch (printSize)
                {
                    //A4
                    case 1: //65 = 5X13
                        rows = 13;
                        cols = 5;
                        break;
                    case 2: //100 = 5x20
                        rows = 20;
                        cols = 5;
                        break;
                    case 3: //180 = 10x18
                        rows = 18;
                        cols = 10;
                        break;
                    //Decan nhiệt
                    case 4: //1 =1X1
                        rect = new iTextSharp.text.Rectangle(40, 20);
                        rows = 1;
                        cols = 1;
                        break;
                    case 5://2 = 2x1
                        rect = new iTextSharp.text.Rectangle(80, 20);
                        rows = 1;
                        cols = 2;
                        break;
                }
                #endregion

                bool IsShowProductName = true;
                bool IsShowPrice = true;
                #region get item info
                switch (itemInfo)
                {
                    case 1: //show barcode only
                        IsShowPrice = false;
                        IsShowProductName = false;
                        break;
                    case 2: //barcode and productname
                        IsShowPrice = false;
                        IsShowProductName = true;
                        break;
                    case 3: //barcode and price
                        IsShowPrice = true;
                        IsShowProductName = false;
                        break;
                    case 4: //all
                        IsShowPrice = true;
                        IsShowProductName = true;
                        break;
                }
                #endregion
                //====================================
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
                        product.IsShowPrice = IsShowPrice;
                        product.IsShowProductName = IsShowProductName;
                        listPDFItems.Add(product);
                    }
                }

                MemoryStream stream = new MemoryStream(new byte[2000]);
                string filename = "MaVach_" + SessionCollection.CurrentUserId + "_" + SessionCollection.CurrentStore
                            + "_" + DateTime.Now.ToString(" dd-MM-yyyy hh_mm_ss") + ".pdf";
                string path =  Server.MapPath(ConfigurationManager.AppSettings["ExportedBarcodePDF"] + filename);

                ProductBarcodeHelper.CreatePDF(path, listPDFItems, rows, cols,rect);
                //ProductBarcodeHelper.CreateBarcode(path);

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