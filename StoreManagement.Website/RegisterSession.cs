using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace StoreManagement.Website
{
    public static class RegisterSession
    {
        public static string UserName
        {
            get { return (string)(GetKey("register_username",""));} 
            set { SetKey("register_username", value);}
        }

        public static string Email
        {
            get { return (string)(GetKey("register_email", "")); }
            set { SetKey("register_email", value); }
        }

        public static string StoreName
        {
            get { return (string)(GetKey("register_storename", "")); }
            set { SetKey("register_storename", value); }
        }

      
        //===================================
        private static object GetKey(string key, object defaultValue)
        {
            return HttpContext.Current.Session[key] == null ? defaultValue : HttpContext.Current.Session[key];
        }

        private static void SetKey(string key,object value)
        {
            HttpContext.Current.Session[key] = value;
        }

    }
}