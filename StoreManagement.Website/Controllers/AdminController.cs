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

        // GET: Admin
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult General()
        {
            return CheckSession();
        }

        public ActionResult Orders(string DateRangeCode, string Status)
        {
            ViewBag.DateRangeCode = DateRangeCode;
            ViewBag.Status = Status;
            return CheckSession();
        }

        public ActionResult Products(string ProductType)
        {
            ViewBag.ProductType = ProductType;
            return CheckSession();
        }


        public ActionResult Customers()
        {
            return CheckSession();
        }

        public ActionResult Purchase()
        {
            return CheckSession();
        }

        public ActionResult Inventory(string InventoryProductType)
        {
            ViewBag.InventoryProductType = InventoryProductType;
            return CheckSession();
        }

        public ActionResult Revenue()
        {
            return CheckSession();
        }

        public ActionResult Payment()
        {
            return CheckSession();
        }

        public ActionResult Profit(string DateRangeCode)
        {
            ViewBag.DateRangeCode = DateRangeCode;
            return CheckSession();
        }

        public ActionResult Setting()
        {
            return CheckSession();
        }

        public ActionResult Exception()
        {
            return CheckSession();
        }

        public ActionResult LogData()
        {
            return CheckSession();
        }

        public ActionResult Announcement()
        {
            return CheckSession();
        }
    }
}