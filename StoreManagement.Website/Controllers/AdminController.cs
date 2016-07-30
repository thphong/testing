using StoreManagement.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace StoreManagement.Website.Controllers
{
    public class AdminController : BaseController
    {
        
        public AdminController (IDataService _dataService) : base (_dataService)
        {
        }

        [HttpGet]
        public ActionResult Index()
        {
            return CheckSession();
        }

        
        [HttpGet]
        public ActionResult General()
        {
            SessionCollection.LastUrl = "/Admin/General";
            return PartialView("General");
        }

        
        [HttpGet]
        public ActionResult Orders(string DateRangeCode, string Status)
        {
            ViewBag.DateRangeCode = DateRangeCode;
            ViewBag.Status = Status;
            SessionCollection.LastUrl = "/Admin/Orders";
            return PartialView("Orders");
        }

        
        [HttpGet]
        public ActionResult Products(string ProductType)
        {
            SessionCollection.LastUrl = "/Admin/Products";
            ViewBag.ProductType = ProductType;
            return PartialView("Products");
        }

        
        [HttpGet]
        public ActionResult Customers()
        {
            SessionCollection.LastUrl = "/Admin/Customers";
            return PartialView("Customers");
        }

        
        [HttpGet]
        public ActionResult Purchase()
        {
            SessionCollection.LastUrl = "/Admin/Purchase";
            return PartialView("Purchase");
        }

        
        [HttpGet]
        public ActionResult Inventory(string InventoryProductType)
        {
            SessionCollection.LastUrl = "/Admin/Inventory";
            ViewBag.InventoryProductType = InventoryProductType;
            return PartialView("Inventory");
        }

        
        [HttpGet]
        public ActionResult Revenue(string DateRangeCode)
        {
            SessionCollection.LastUrl = "/Admin/Revenue";
            ViewBag.DateRangeCode = DateRangeCode;
            return PartialView("Revenue");
        }

        
        [HttpGet]
        public ActionResult Payment()
        {
            SessionCollection.LastUrl = "/Admin/Payment";
            return PartialView("Payment");
        }

        
        [HttpGet]
        public ActionResult Profit(string DateRangeCode)
        {
            SessionCollection.LastUrl = "/Admin/Profit";
            ViewBag.DateRangeCode = DateRangeCode;
            return PartialView("Profit");
        }

        
        [HttpGet]
        public ActionResult Setting()
        {
            SessionCollection.LastUrl = "/Admin/Setting";
            return PartialView("Setting");
        }

        
        [HttpGet]
        public ActionResult Exception()
        {
            SessionCollection.LastUrl = "/Admin/Exception";
            return PartialView("Exception");
        }
                
        [HttpGet]
        public ActionResult LogData()
        {
            SessionCollection.LastUrl = "/Admin/LogData";
            return PartialView("LogData");
        }
        
        [HttpGet]
        public ActionResult Announcement()
        {
            SessionCollection.LastUrl = "/Admin/Announcement";
            return PartialView("Announcement");
        }
    }
}