﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoreManagement.Common.Import
{
    public class ProductImporter : iImporter
    {
        public ProductImporter()
        {
        }

        public DataTable Import(DataTable data)
        {
            DataTable error = null;
            return error;
        }
    }
}
