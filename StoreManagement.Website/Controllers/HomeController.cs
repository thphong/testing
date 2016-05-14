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
        
        public HomeController(IDataService _dataService) : base(_dataService)
        {
        }

        public ActionResult Index()
        {
            if (SessionCollection.IsLogIn)
            {
                return RedirectToAction("General", "Admin");
            }
            else
            {
                return RedirectToAction("Login", "Account");
            }
        }
    }
}
