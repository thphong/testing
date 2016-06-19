﻿using StoreManagement.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace StoreManagement.Website.Controllers
{
    public class AccountController : BaseController
    {
        public AccountController(IDataService _dataService) : base(_dataService)
        {
        }

        public ActionResult Login()
        {
            if (SessionCollection.IsLogIn)
            {
                return RedirectToAction(SessionCollection.DefaultController, SessionCollection.DefaultAction);
            }
            else
            {
                return View();
            }
        }

        public ActionResult Info()
        {
            return CheckSession();
        }

        public ActionResult Error()
        {
            if (SessionCollection.IsLogIn)
            {
                return View();
            }
            else
            {
                return RedirectToAction("Login", "Account");
            }
        }


        [HttpPost]
        public ActionResult Login(string loginId, string password)
        {
            try
            {
                var result = dataService.Login(loginId, password);
                SessionCollection.CurrentUserId = (int)result["UserId"];
                SessionCollection.UserName = (string)result["UserName"];
                SessionCollection.CurrentStore = (int)result["CurrentStore"];
                SessionCollection.ProductGroup = (int)result["ProductGroup"];
                SessionCollection.StoreName = (string)result["StoreName"];
                SessionCollection.StorePhone = (string)result["StorePhone"];
                SessionCollection.StoreAddress = (string)result["StoreAddress"];
                SessionCollection.DefaultAction = (string)result["DefaultAction"];
                SessionCollection.DefaultController = (string)result["DefaultController"];
                SessionCollection.IsLogIn = true;
                return Json(true);
            }
            catch (Exception ex)
            {
                return Json(false);
            }
        }

        [HttpPost]
        public ActionResult Logout()
        {
            SessionCollection.ClearSession();
            return Json(true);
        }
    }
}