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
        public AccountController(IDataService _dataService) : base (_dataService)
        {
        }

        public ActionResult Login()
        {
            return View();
        }
    }
}