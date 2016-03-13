using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoreManagement.Service
{
    public class GridViewConfig
    {
        public const string TableType = "table";
        public const string FunctionType = "function";

        public int StartRow { get; set; }
        public int EndRow { get; set; }
        public string FilterByValue
        {
            get
            {
                return FilterBy != null ? FilterBy : "";
            }
        }
        public string FilterBy { get; set; }
        public string OrderBy { get; set; }
        public int OrderDirection { get; set; }
        public string DirectionString
        {
            get
            {
                return OrderDirection > 0 ? "ASC" : "DESC";
            }
        }

        public int NumRow
        {
            get
            {
                return EndRow - StartRow + 1;
            }
        }

        #region Data Config
        public string GridId { get; set; }
        public string GridDataAction { get; set; }
        public string GridDataType { get; set; }
        public string GridDataObject { get; set; }
        public string GridFilterCondition { get; set; }
        public string GridSortCondition { get; set; }
        public string GridDefinedColums { get; set; }
        public string GridSumColums { get; set; }
        public string GridParameters { get; set; }
        #endregion
    }
}
