using StoreManagement.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace StoreManagement.Website
{
    public static class SessionCollection
    {
        public static int CurrentUserId
        {
            get
            {
                return (int)HttpContext.Current.Session["CurrentUserId"];
            }
            set
            {
                HttpContext.Current.Session["CurrentUserId"] = value;
            }
        }

        public static GridViewConfig ExportConfig
        {
            get
            {
                return (GridViewConfig)HttpContext.Current.Session["ExportConfig"];
            }
            set
            {
                HttpContext.Current.Session["ExportConfig"] = value;
            }
        }

        public static Dictionary<string, object> ExportObjectData
        {
            get
            {
                return (Dictionary<string, object>)HttpContext.Current.Session["ExportObjectData"];
            }
            set
            {
                HttpContext.Current.Session["ExportObjectData"] = value;
            }
        }

        public static string ExportTemplate
        {
            get
            {
                return (string)HttpContext.Current.Session["ExportTemplate"];
            }
            set
            {
                HttpContext.Current.Session["ExportTemplate"] = value;
            }
        }


        public static int CurrentStore
        {
            get
            {
                return (int)HttpContext.Current.Session["CurrentStore"];
            }
            set
            {
                HttpContext.Current.Session["CurrentStore"] = value;
            }
        }
    }
}