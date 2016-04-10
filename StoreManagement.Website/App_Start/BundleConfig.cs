﻿using System.Web;
using System.Web.Optimization;

namespace StoreManagement.Website
{
    public class BundleConfig
    {
        // For more information on Bundling, visit http://go.microsoft.com/fwlink/?LinkId=254725
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryui").Include(
                        "~/Scripts/jquery-ui.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                        "~/Scripts/jquery.unobtrusive*",
                        "~/Scripts/jquery.validate*"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new StyleBundle("~/Content/css").Include("~/Content/site.css", "~/Content/FValidation.css"));

            bundles.Add(new StyleBundle("~/Content/jqueryui").Include(
                        "~/Content/jquery-ui.css"));

            bundles.Add(new ScriptBundle("~/bundles/angularjs").Include(
                        "~/Scripts/angular.js"));

            bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                        "~/Scripts/bootstrap.js",
                        "~/Scripts/bootstrap-notify.js",
                        "~/Scripts/bootstrap-datepicker.js"));

            bundles.Add(new ScriptBundle("~/bundles/masterpage").Include(
                        "~/Scripts/masterpage.js"));

            bundles.Add(new StyleBundle("~/Content/bootstrap").Include(
                        "~/Content/bootstrap.css",
                        "~/Content/bootstrap-notify.css",
                        //"~/Content/bootstrap-datepicker.standalone.css",
                        //"~/Content/bootstrap-datepicker3.standalone.css",
                        //"~/Content/bootstrap-datepicker.css",
                        "~/Content/bootstrap-datepicker3.css"));

            bundles.Add(new StyleBundle("~/Content/sbadmin").Include(
                        "~/Content/sb-admin-2.css",
                        "~/Content/timeline.css",
                        "~/Content/metisMenu.css"));

            bundles.Add(new ScriptBundle("~/bundles/sbadminScript").Include(
                        "~/Scripts/metisMenu.js",
                        "~/Scripts/sb-admin-2.js"));

            bundles.Add(new StyleBundle("~/Content/fontawesome").Include(
                        "~/Content/font-awesome.css"));

            bundles.Add(new StyleBundle("~/Content/C3Chart").Include(
                        "~/Content/c3.css"));

            bundles.Add(new ScriptBundle("~/bundles/C3Chart").Include(
                            "~/Scripts/d3.js",
                            "~/Scripts/c3.js"));

            bundles.Add(new ScriptBundle("~/bundles/common").Include(
                        "~/Scripts/Common/Common.js",
                        "~/Scripts/Common/DataObject.js",
                        "~/Scripts/Common/AngularGridView.js",
                        "~/Scripts/Common/FValidationScript.js",
                        "~/Scripts/Common/jquery.showLoading.min.js",
                        "~/Scripts/Common/AngularTranslationService.js",
                        "~/Scripts/Common/LoadMenu.js"));

            bundles.Add(new ScriptBundle("~/bundles/DataList").Include(
                        "~/Scripts/DataService/DataList.js"));

            bundles.Add(new ScriptBundle("~/bundles/Customer").Include(
                        "~/Scripts/Controller/Customer.js"));
            bundles.Add(new ScriptBundle("~/bundles/CustomerModal").Include(
                        "~/Scripts/Controller/CustomerModal.js"));
            bundles.Add(new ScriptBundle("~/bundles/SupplierModal").Include(
                        "~/Scripts/Controller/SupplierModal.js"));

            bundles.Add(new ScriptBundle("~/bundles/Product").Include(
                        "~/Scripts/Controller/Product.js"));
            bundles.Add(new ScriptBundle("~/bundles/ProductGroup").Include(
                        "~/Scripts/Controller/ProductGroup.js"));
            bundles.Add(new ScriptBundle("~/bundles/Producer").Include(
                        "~/Scripts/Controller/Producer.js"));
            bundles.Add(new ScriptBundle("~/bundles/Attribute").Include(
                        "~/Scripts/Controller/Attribute.js"));
            bundles.Add(new ScriptBundle("~/bundles/Order").Include(
                        "~/Scripts/Controller/Order.js"));
            bundles.Add(new ScriptBundle("~/bundles/Purchase").Include(
                        "~/Scripts/Controller/Purchase.js"));
            bundles.Add(new ScriptBundle("~/bundles/Inventory").Include(
                        "~/Scripts/Controller/Inventory.js"));
            bundles.Add(new ScriptBundle("~/bundles/Payment").Include(
                        "~/Scripts/Controller/Payment.js"));
            bundles.Add(new ScriptBundle("~/bundles/CostType").Include(
                        "~/Scripts/Controller/CostType.js"));
            bundles.Add(new ScriptBundle("~/bundles/Revenue").Include(
                        "~/Scripts/Controller/Revenue.js"));

            bundles.Add(new ScriptBundle("~/bundles/ProductQuanHistory").Include(
                        "~/Scripts/Controller/ProductQuanHistory.js"));

        }
    }
}