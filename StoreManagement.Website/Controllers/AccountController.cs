using StoreManagement.Service;
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
                return RedirectToAction(SessionCollection.DefaultAction, SessionCollection.DefaultController);
            }
            else
            {
                return View();
            }
        }

        [HttpGet]
        public ActionResult Info()
        {
            return PartialView("Info");
        }

        [HttpGet]
        public ActionResult POSInfo()
        {
            return View("Index");
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
                SessionCollection.UserName = result["UserName"].ToString();
                SessionCollection.CurrentStore = (int)result["CurrentStore"];
                SessionCollection.StoreName = result["StoreName"].ToString();
                SessionCollection.StorePhone = result["StorePhone"].ToString();
                SessionCollection.StoreAddress = result["StoreAddress"].ToString();
                SessionCollection.DefaultAction = result["DefaultAction"].ToString();
                SessionCollection.DefaultController = result["DefaultController"].ToString();
                SessionCollection.IsDeveloper = (bool)result["IsDeveloper"];
                SessionCollection.ParentStore = (int)result["ParentStore"];
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
            dataService.Logout(SessionCollection.CurrentUserId);
            SessionCollection.ClearSession();
            SessionCollection.IsLogOut = true;
            return Json(true);
        }

        [HttpPost]
        public ActionResult Register(
            string name, string username, string email, string password,
            string storename, string phone, string address, string city, int productgroup
            )
        {
            SessionCollection.ClearSession();
            try
            {
                var result = dataService.Register(name, username, email, password,
                                storename, phone, address, city, productgroup);

                RegisterSession.UserName = username;
                RegisterSession.Email = email;
                RegisterSession.StoreName = storename;
                return Json(true);
            }
            catch (Exception ex)
            {
                return Json("#error:" + ex.Message);
            }
        }
    }
}