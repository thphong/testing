using StoreManagement.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace StoreManagement.Website.Controllers
{
    public class POSController : BaseController
    {
        public POSController(IDataService _dataService) : base(_dataService)
        {
        }

        // GET: POS
        public ActionResult Index()
        {
            return CheckSession();
        }

        [HttpGet]
        public ActionResult POSReport()
        {
            return PartialView("POSReport");
        }

        [HttpGet]
        public ActionResult POSInventory()
        {
            return PartialView("POSInventory");
        }

        [HttpGet]
        public ActionResult POSAnnounement()
        {
            return PartialView("POSAnnounement");
        }
    }
}