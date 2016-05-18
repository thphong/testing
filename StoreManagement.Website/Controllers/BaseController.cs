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

        public BaseController(IDataService _dataService)
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
                string actionName = this.ControllerContext.RouteData.Values["action"].ToString();
                string controllerName = this.ControllerContext.RouteData.Values["controller"].ToString();
                if (controllerName != "Account")
                {
                    var gridConfig = new GridViewConfig
                    {
                        GridDataObject = "dbo.UFN_System_Get_Menu",
                        GridDataType = "function",
                        GridParameters = SessionCollection.CurrentUserId.ToString(),
                        GridDataAction = "count",
                        FilterBy = controllerName + "/" + actionName

                    };

                    int count = dataService.CountDataFromConfiguration(SessionCollection.CurrentUserId, gridConfig);

                    if (count <= 0)
                    {
                        return RedirectToAction("Error", "Account"); 
                    }
                }

                return View();
            }
        }
    }
}
