using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace StoreManagement.Website
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
               name: "Document",
               url: "Document/{page}",
               defaults: new { controller = "Home", action = "Document", page = UrlParameter.Optional }
            );
            routes.MapRoute(
               name: "DownloadFile",
               url: "download/{fileid}",
               defaults: new { controller = "Data", action = "DownloadFile", fileid = UrlParameter.Optional }
           );

            routes.MapRoute(
                name: "DownloadExcelTemplate",
                url: "template/{template}",
                defaults: new { controller = "Data", action = "DownloadExcelTemplate", template = UrlParameter.Optional }
            );

            //=============================
            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
            );

           
        }
    }
}