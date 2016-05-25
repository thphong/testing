using StoreManagement.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace StoreManagement.Website
{
    public static class SessionCollection
    {
        public static bool IsLogIn
        {
            get
            {
                return HttpContext.Current.Session["IsLogIn"] == null ? false : (bool)HttpContext.Current.Session["IsLogIn"];
            }
            set
            {
                HttpContext.Current.Session["IsLogIn"] = value;
            }
        }

        public static int CurrentUserId
        {
            get
            {
                return HttpContext.Current.Session["CurrentUserId"] != null ? (int)HttpContext.Current.Session["CurrentUserId"] : -1;
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
                return HttpContext.Current.Session["CurrentStore"] != null ? (int)HttpContext.Current.Session["CurrentStore"] : -1;
            }
            set
            {
                HttpContext.Current.Session["CurrentStore"] = value;
            }
        }

        public static int ProductGroup
        {
            get
            {
                return HttpContext.Current.Session["ProductGroup"] != null ? (int)HttpContext.Current.Session["ProductGroup"] : -1;
            }
            set
            {
                HttpContext.Current.Session["ProductGroup"] = value;
            }
        }

        public static void ClearSession()
        {
            HttpContext.Current.Session.Clear();
        }
    }
}