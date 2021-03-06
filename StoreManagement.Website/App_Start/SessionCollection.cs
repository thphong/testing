﻿using StoreManagement.Service;
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

        public static bool IsLogOut
        {
            get
            {
                return HttpContext.Current.Session["IsLogOut"] == null ? false : (bool)HttpContext.Current.Session["IsLogOut"];
            }
            set
            {
                HttpContext.Current.Session["IsLogOut"] = value;
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

        public static string UserName
        {
            get
            {
                return (string)HttpContext.Current.Session["UserName"];
            }
            set
            {
                HttpContext.Current.Session["UserName"] = value;
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

        public static string StoreName
        {
            get
            {
                return (string)HttpContext.Current.Session["StoreName"];
            }
            set
            {
                HttpContext.Current.Session["StoreName"] = value;
            }
        }

        public static string StoreAddress
        {
            get
            {
                return (string)HttpContext.Current.Session["StoreAddress"];
            }
            set
            {
                HttpContext.Current.Session["StoreAddress"] = value;
            }
        }

        public static string StorePhone
        {
            get
            {
                return (string)HttpContext.Current.Session["StorePhone"];
            }
            set
            {
                HttpContext.Current.Session["StorePhone"] = value;
            }
        }

        public static void ClearSession()
        {
            HttpContext.Current.Session.Clear();
        }

        public static string DefaultAction
        {
            get
            {
                return (string)HttpContext.Current.Session["DefaultAction"];
            }
            set
            {
                HttpContext.Current.Session["DefaultAction"] = value;
            }
        }

        public static string DefaultController
        {
            get
            {
                return (string)HttpContext.Current.Session["DefaultController"];
            }
            set
            {
                HttpContext.Current.Session["DefaultController"] = value;
            }
        }

        public static string LastUrl
        {
            get
            {
                return (string)HttpContext.Current.Session["LastUrl"];
            }
            set
            {
                HttpContext.Current.Session["LastUrl"] = value;
            }
        }

        public static bool IsDeveloper
        {
            get
            {
                return HttpContext.Current.Session["IsDeveloper"] != null ? (bool)HttpContext.Current.Session["IsDeveloper"] : false;
            }
            set
            {
                HttpContext.Current.Session["IsDeveloper"] = value;
            }
        }

        public static int ParentStore
        {
            get
            {
                return HttpContext.Current.Session["ParentStore"] != null ? (int)HttpContext.Current.Session["ParentStore"] : 0;
            }
            set
            {
                HttpContext.Current.Session["ParentStore"] = value;
            }
        }

        public static int TriggerCreateSampleData
        {
            get
            {
                return HttpContext.Current.Session["TriggerCreateSampleData"] != null ? (int)HttpContext.Current.Session["TriggerCreateSampleData"] : 0;
            }
            set
            {
                HttpContext.Current.Session["TriggerCreateSampleData"] = value;
            }
        }

    }
}