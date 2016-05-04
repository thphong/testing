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
            return View();
        }

        public ActionResult Orders(string DateRangeCode, string Status)
        {
            ViewBag.DateRangeCode = DateRangeCode;
            ViewBag.Status = Status;
            return View();
        }

        public ActionResult Products(string ProductType)
        {
            ViewBag.ProductType = ProductType;
            return View();
        }


        public ActionResult Customers()
        {
            return View();
        }

        public ActionResult Purchase()
        {
            return View();
        }

        public ActionResult Inventory(string InventoryProductType)
        {
            ViewBag.InventoryProductType = InventoryProductType;
            return View();
        }

        public ActionResult Revenue()
        {
            return View();
        }

        public ActionResult Payment()
        {
            return View();
        }

        public ActionResult Profit()
        {
            return View();
        }

        public ActionResult Setting()
        {
            return View();
        }

        public ActionResult Exception()
        {
            return View();
        }

        public ActionResult LogData()
        {
            return View();
        }
    }
}