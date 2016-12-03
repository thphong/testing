using StoreManagement.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace StoreManagement.Website.Controllers
{
    public class HomeController : BaseController
    {

        public HomeController(IDataService _dataService)
            : base(_dataService)
        {
        }

        public ActionResult Index()
        {
            HttpCookie cookie = Request.Cookies["Username"];
            
            if (cookie != null && !SessionCollection.IsLogIn)
            {
                return RedirectToAction("Login", "Account");
            }
            return View();
        }

        public ActionResult AboutUs()
        {
            return View();
        }

        public ActionResult Document()
        {

            string page = "dang-ky";
            if (!string.IsNullOrEmpty(Request.Params["page"]))
                page = Request.Params["page"];
            ViewBag.CurrentPage = page;
            return View();
        }


        public ActionResult Products()
        {
            return View();
        }

        public ActionResult Clients()
        {
            return View();
        }

        public ActionResult News()
        {
            return View();
        }

        public ActionResult TermOfUse()
        {
            return View();
        }

        public ActionResult Support()
        {
            return View();
        }

        public ActionResult FAQ()
        {
            return View();
        }

        public ActionResult PageNotFound()
        {
            return View();
        }

        public ActionResult ContactUs()
        {
            return View();
        }

        public ActionResult Register()
        {
            return View();
        }

        public ActionResult RegisterSuccess()
        {
            return View();
        }
    }
}
