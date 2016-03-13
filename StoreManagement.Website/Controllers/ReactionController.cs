using StoreManagement.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace StoreManagement.Website.Controllers
{
    public class ReactionController : BaseController
    {
        IDataService dataService;

        public ReactionController(IDataService _dataService)
        {
            dataService = _dataService;
        }

        public ActionResult Input()
        {
            return View();
        }

    }
}
