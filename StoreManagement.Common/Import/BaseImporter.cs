﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoreManagement.Common.Import
{
    public interface iImporter
    {
        DataTable Import(DataTable data);

        
    }

    public class ImporterHelper
    {
        public static iImporter GetImporter(string template)
        {
            iImporter importer = null;
            if (template == "Customers")
            {
                importer = new CustomerImporter();
            }
            else if (template == "Products")
            {
                importer = new ProductImporter();
            }
            else if (template == "Suppliers")
            {
                importer = new SupplierImporter();
            }
            return importer;
        }

        public static string GetDBTableName(string template)
        {
            string  dbtable = "T_ExcelImportData_" + template;
            return dbtable;
        }

        
    }
}
