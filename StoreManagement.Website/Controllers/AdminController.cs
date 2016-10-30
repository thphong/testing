using StoreManagement.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace StoreManagement.Website.Controllers
{
    public class AdminController : BaseController
    {
        
        public AdminController (IDataService _dataService) : base (_dataService)
        {
        }

        [HttpGet]
        public ActionResult Index()
        {
            return CheckSession();
        }

        
        [HttpGet]
        public ActionResult General()
        {
            SessionCollection.LastUrl = "/Admin/General";
            return PartialView("General");
        }

        
        [HttpGet]
        public ActionResult Orders(string DateRangeCode, string Status, string OrderType)
        {
            ViewBag.DateRangeCode = DateRangeCode;
            ViewBag.Status = Status;
            ViewBag.OrderType = OrderType;
            SessionCollection.LastUrl = "/Admin/Orders";
            return PartialView("Orders");
        }

        
        [HttpGet]
        public ActionResult Products(string ProductType)
        {
            SessionCollection.LastUrl = "/Admin/Products";
            ViewBag.ProductType = ProductType;
            return PartialView("Products");
        }

        [HttpGet]
        public ActionResult ProductDetail()
        {
            return PartialView("ProductDetail");
        }

        [HttpGet]
        public ActionResult ComboDetail()
        {
            return PartialView("ComboDetail");
        }

        [HttpGet]
        public ActionResult ProductPriceHistoryModal()
        {
            return PartialView("ProductPriceHistoryModal");
        }

        [HttpGet]
        public ActionResult ProductGroupModal()
        {
            return PartialView("ProductGroupModal");
        }

        [HttpGet]
        public ActionResult ProducerModal()
        {
            return PartialView("ProducerModal");
        }

        [HttpGet]
        public ActionResult AttributeModal()
        {
            return PartialView("AttributeModal");
        }

        [HttpGet]
        public ActionResult ProductQuantityHistory()
        {
            return PartialView("ProductQuantityHistory");
        }

        [HttpGet]
        public ActionResult SupplierModal()
        {
            return PartialView("SupplierModal");
        }

        [HttpGet]
        public ActionResult CustomerModal()
        {
            return PartialView("CustomerModal");
        }

        [HttpGet]
        public ActionResult PurchaseDetail()
        {
            return PartialView("PurchaseDetail");
        }

        [HttpGet]
        public ActionResult PromotionStore()
        {
            return PartialView("PromotionStore");
        }

        [HttpGet]
        public ActionResult PrintTermModal()
        {
            return PartialView("PrintTermModal");
        }

        [HttpGet]
        public ActionResult RolesModal()
        {
            return PartialView("RolesModal");
        }

        [HttpGet]
        public ActionResult UserModal()
        {
            return PartialView("UserModal");
        }

        [HttpGet]
        public ActionResult CostModal()
        {
            return PartialView("CostModal");
        }

        [HttpGet]
        public ActionResult CostPholoModal()
        {
            return PartialView("CostPholoModal");
        }

        [HttpGet]
        public ActionResult CostTypeModal()
        {
            return PartialView("CostTypeModal");
        }

        [HttpGet]
        public ActionResult ReceiveHistoryModal()
        {
            return PartialView("ReceiveHistoryModal");
        }

        [HttpGet]
        public ActionResult OrderDetail()
        {
            return PartialView("OrderDetail");
        }

        [HttpGet]
        public ActionResult InventTranForm()
        {
            return PartialView("InventTranForm");
        }

        [HttpGet]
        public ActionResult InventoryForm()
        {
            return PartialView("InventoryForm");
        }

        [HttpGet]
        public ActionResult AnnouncementModal()
        {
            return PartialView("AnnouncementModal");
        }

        [HttpGet]
        public ActionResult SupplierDetail()
        {
            return PartialView("SupplierDetail");
        }

        [HttpGet]
        public ActionResult CustomerDetail()
        {
            return PartialView("CustomerDetail");
        }

        [HttpGet]
        public ActionResult Customers()
        {
            SessionCollection.LastUrl = "/Admin/Customers";
            return PartialView("Customers");
        }

        
        [HttpGet]
        public ActionResult Purchase()
        {
            SessionCollection.LastUrl = "/Admin/Purchase";
            return PartialView("Purchase");
        }

        
        [HttpGet]
        public ActionResult Inventory(string InventoryProductType)
        {
            SessionCollection.LastUrl = "/Admin/Inventory";
            ViewBag.InventoryProductType = InventoryProductType;
            return PartialView("Inventory");
        }

        
        [HttpGet]
        public ActionResult Revenue(string DateRangeCode)
        {
            SessionCollection.LastUrl = "/Admin/Revenue";
            ViewBag.DateRangeCode = DateRangeCode;
            return PartialView("Revenue");
        }

        
        [HttpGet]
        public ActionResult Payment()
        {
            SessionCollection.LastUrl = "/Admin/Payment";
            return PartialView("Payment");
        }

        
        [HttpGet]
        public ActionResult Profit(string DateRangeCode)
        {
            SessionCollection.LastUrl = "/Admin/Profit";
            ViewBag.DateRangeCode = DateRangeCode;
            return PartialView("Profit");
        }

        
        [HttpGet]
        public ActionResult Setting()
        {
            SessionCollection.LastUrl = "/Admin/Setting";
            return PartialView("Setting");
        }

        
        [HttpGet]
        public ActionResult Exception()
        {
            SessionCollection.LastUrl = "/Admin/Exception";
            return PartialView("Exception");
        }
                
        [HttpGet]
        public ActionResult LogData()
        {
            SessionCollection.LastUrl = "/Admin/LogData";
            return PartialView("LogData");
        }

        [HttpGet]
        public ActionResult SQL()
        {
            SessionCollection.LastUrl = "/Admin/SQL";
            return PartialView("SQL");
        }

        [HttpGet]
        public ActionResult Announcement()
        {
            SessionCollection.LastUrl = "/Admin/Announcement";
            return PartialView("Announcement");
        }

        [HttpGet]
        public ActionResult ManageStore()
        {
            SessionCollection.LastUrl = "/Admin/ManageStore";
            return PartialView("ManageStore");
        }

        [HttpGet]
        public ActionResult ExtendStoreModal()
        {
            return PartialView("ExtendStoreModal");
        }
    }
}