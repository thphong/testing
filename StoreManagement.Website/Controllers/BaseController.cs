using StoreManagement.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace StoreManagement.Website.Controllers
{
    public class BaseController : Controller
    {
        protected IDataService dataService;

        public BaseController (IDataService _dataService)
        {
            dataService = _dataService;
        }

        public ActionResult CheckSession()
        {
            if (!SessionCollection.IsLogIn)
            {
                return RedirectToAction("Login", "Account");
            }
            else
            {
                return View();
            }
        }
    }
}
