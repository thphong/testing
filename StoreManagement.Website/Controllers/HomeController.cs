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
        IDataService dataService;

        public HomeController(IDataService _dataService)
        {
            dataService = _dataService;
        }

        public ActionResult Index()
        {
            //var a = chemBusiness.GetAllQuestion().ToList();
            //var x = a[0];
            //return View();

            //return View("Input", "Data");
            return RedirectToAction("General", "Admin" );
        }
    }
}
