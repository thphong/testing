using StoreManagement.Service;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

namespace StoreManagement.Website
{
    // Note: For instructions on enabling IIS6 or IIS7 classic mode, 
    // visit http://go.microsoft.com/?LinkId=9394801

    public class MvcApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();

            WebApiConfig.Register(GlobalConfiguration.Configuration);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
            AuthConfig.RegisterAuth();
        }

        protected void Session_Start()
        {
        }

        protected void Session_End()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ToString();
            var dataService = new DataService(new DatabaseFactory(connectionString));  //DependencyResolver.Current.GetService<DataService>();
            dataService.Logout(int.Parse(Session["CurrentUserId"].ToString()));
        }

        protected void Application_BeginRequest()
        {
            //if (!Context.Request.IsSecureConnection)
                //Response.Redirect(Context.Request.Url.ToString().Replace("http:", "https:"));
        }
    }
}