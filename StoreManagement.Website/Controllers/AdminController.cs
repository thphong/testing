﻿using StoreManagement.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace StoreManagement.Website.Controllers
{
    public class AdminController : BaseController
    {
        public IDataService dataService;

        public AdminController (IDataService _dataService)
        {
            dataService = _dataService;
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

        public ActionResult Orders()
        {
            return View();
        }

        public ActionResult Products()
        {
            return View();
        }


        public ActionResult Customers()
        {
            return View();
        }

        public ActionResult Warehouses()
        {
            return View();
        }

        public ActionResult Inventory()
        {
            return View();
        }

        public ActionResult Sales()
        {
            return View();
        }

        public ActionResult InOutCome()
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
    }
}