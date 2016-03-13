using AutoMapper;
using StoreManagement.Data;
using SharpRepository.Repository;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity.Core.EntityClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Reflection;
using System.Data.SqlClient;

namespace StoreManagement.Service
{
    public class DataService : IDataService
    {

        private IDatabaseFactory dbFactory;

        #region Contrcuter
        public DataService(IDatabaseFactory _dbFactory)
        {
            this.dbFactory = _dbFactory;
            //chemRep = this.dbFactory.GetRepository<T_Chemical>();
        }
        #endregion

        #region Get List
        public DataTable GetDataFromConfiguration(int userId, GridViewConfig gridConfig)
        {
            string statement;
            
            if(gridConfig.GridDataType == GridViewConfig.FunctionType)
            {
                statement = string.Format("exec [dbo].[USP_System_Data_Function_Get] @FunctionName = '{0}', @Parameter = N'{1}', @TextFilter = N'{2}', @Action = '{3}', @StartRow = {4}, @EndRow = {5}, @GlobalOrder = '{6}', @GlobalOrderDirection = {7}, @ColumSum = '{8}'"
                    , gridConfig.GridDataObject, gridConfig.GridParameters, gridConfig.FilterByValue, gridConfig.GridDataAction, gridConfig.StartRow, gridConfig.EndRow, gridConfig.OrderBy, gridConfig.OrderDirection, gridConfig.GridSumColums);
            }
            else
            {
                statement = string.Format("exec [dbo].[USP_System_Data_List_Get] @TableName = '{0}', @Colums = '{1}', @Condition = N'{2}', @OrderColums = '{3}', @TextFilter = N'{4}', @Action = '{5}', @StartRow = {6}, @EndRow = {7}, @GlobalOrder = '{8}', @GlobalOrderDirection = {9}, @ColumSum = '{10}'"
                    , gridConfig.GridDataObject, gridConfig.GridDefinedColums, gridConfig.GridFilterCondition, gridConfig.GridSortCondition, gridConfig.FilterByValue, gridConfig.GridDataAction, gridConfig.StartRow, gridConfig.EndRow, gridConfig.OrderBy, gridConfig.OrderDirection, gridConfig.GridSumColums);
            }

            DataSet retVal = new DataSet();
            SqlConnection sqlConn = (SqlConnection)dbFactory.GetContext().Database.Connection;
            SqlCommand cmdReport = new SqlCommand(statement, sqlConn);
            SqlDataAdapter daReport = new SqlDataAdapter(cmdReport);
            using (cmdReport)
            {
                cmdReport.CommandType = CommandType.Text;
                daReport.Fill(retVal);
            }
            return retVal.Tables[0];
        }

        public IList<Dictionary<string, object>> GetDataFromConfigurationJsonable( int userId, GridViewConfig gridConfig)
        {
            List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();
            DataTable dt = GetDataFromConfiguration(userId, gridConfig);
            Dictionary<string, object> row;
            foreach (DataRow dr in dt.Rows)
            {
                row = new Dictionary<string, object>();
                foreach (DataColumn col in dt.Columns)
                {
                    row.Add(col.ColumnName, dr[col]);
                }
                rows.Add(row);
            }
            return rows;
        }

        public int CountDataFromConfiguration(int userId, GridViewConfig gridConfig)
        {
            string statement;

            if(gridConfig.GridDataType == GridViewConfig.FunctionType)
            {
                statement = string.Format("exec [dbo].[USP_System_Data_Function_Get] @FunctionName = '{0}', @Parameter = N'{1}', @TextFilter = N'{2}', @Action = '{3}', @StartRow = {4}, @EndRow = {5}, @GlobalOrder = '{6}', @GlobalOrderDirection = {7}"
                    , gridConfig.GridDataObject, gridConfig.GridParameters, gridConfig.FilterByValue, "count", gridConfig.StartRow, gridConfig.EndRow, gridConfig.OrderBy, gridConfig.OrderDirection);
            }
            else
            {
                statement = string.Format("exec [dbo].[USP_System_Data_List_Get] @TableName = '{0}', @Colums = '{1}', @Condition = N'{2}', @OrderColums = '{3}', @TextFilter = N'{4}', @Action = '{5}', @StartRow = {6}, @EndRow = {7}, @GlobalOrder = '{8}', @GlobalOrderDirection = {9}"
                    , gridConfig.GridDataObject, gridConfig.GridDefinedColums, gridConfig.GridFilterCondition, gridConfig.GridSortCondition, gridConfig.FilterByValue, "count", gridConfig.StartRow, gridConfig.EndRow, gridConfig.OrderBy, gridConfig.OrderDirection);
            }

            int result = dbFactory.GetContext().Database.SqlQuery<int>
                    (statement).FirstOrDefault();
            return result;
        }

        public Dictionary<string, object> SumDataFromConfiguration(int userId, GridViewConfig gridConfig)
        {
            gridConfig.GridDataAction = "sum";
            return GetDataFromConfigurationJsonable(userId, gridConfig).First();
        }

        #endregion

        #region Object
        public void SaveObject(int userId, string tableName, string objectData)
        {
            string statement = string.Format("exec [dbo].[USP_System_Data_Update] @TableName = '{0}', @Data = N'{1}', @UserId = {2}"
                    , tableName, objectData, userId);

            dbFactory.GetContext().Database.ExecuteSqlCommand(statement);            
        }

        public Dictionary<string, object> GetObject(int userId, string tableName, string columName, string columValue)
        {
            string statement = string.Format("exec [dbo].[USP_System_Data_Object_Get] @UserId = {0}, @TableName = '{1}', @ColumName = '{2}', @Value = N'{3}'"
                    , userId, tableName, columName, columValue);

            DataSet retVal = new DataSet();
            SqlConnection sqlConn = (SqlConnection)dbFactory.GetContext().Database.Connection;
            SqlCommand cmdReport = new SqlCommand(statement, sqlConn);
            SqlDataAdapter daReport = new SqlDataAdapter(cmdReport);
            using (cmdReport)
            {
                cmdReport.CommandType = CommandType.Text;
                daReport.Fill(retVal);
            }

            Dictionary<string, object> result = new Dictionary<string, object>();
            DataTable dt = retVal.Tables[0];
            Dictionary<string, object> row;
            foreach (DataRow dr in dt.Rows)
            {
                row = new Dictionary<string, object>();
                foreach (DataColumn col in dt.Columns)
                {                    
                    row.Add(col.ColumnName, dr[col]);
                }
                return row;
            }

            return null;
        }

        public void DeleteObject(int userId, string tableName, string columName, string columValue)
        {
            string statement = string.Format("exec [dbo].[USP_System_Data_Object_Delete] @UserId = {0}, @TableName = '{1}', @ColumName = '{2}', @Value = N'{3}'"
                    , userId, tableName, columName, columValue);

            dbFactory.GetContext().Database.ExecuteSqlCommand(statement);
        }
        #endregion
    }
}
