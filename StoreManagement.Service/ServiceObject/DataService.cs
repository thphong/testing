using AutoMapper;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
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
        }
        #endregion

        #region Get List
        public DataTable GetDataFromConfiguration(int userId, GridViewConfig gridConfig)
        {
            string statement;
            if (gridConfig.GridDataType == GridViewConfig.FunctionType)
            {
                statement = string.Format("exec [dbo].[USP_System_Data_Function_Get] @UserId ={0}, @FunctionName = '{1}', @Parameter = N'{2}', @TextFilter = N'{3}', @Action = '{4}', @StartRow = {5}, @EndRow = {6}, @GlobalOrder = '{7}', @GlobalOrderDirection = {8}, @ColumSum = '{9}'"
                    ,userId, gridConfig.GridDataObject, gridConfig.GridParameters, gridConfig.FilterByValue, gridConfig.GridDataAction, gridConfig.StartRow, gridConfig.EndRow, gridConfig.OrderBy, gridConfig.OrderDirection, gridConfig.GridSumColums);
            }
            else
            {
                statement = string.Format("exec [dbo].[USP_System_Data_List_Get] @UserId ={0}, @TableName = '{1}', @Colums = '{2}', @Condition = N'{3}', @OrderColums = '{4}', @TextFilter = N'{5}', @Action = '{6}', @StartRow = {7}, @EndRow = {8}, @GlobalOrder = '{9}', @GlobalOrderDirection = {10}, @ColumSum = '{11}'"
                    ,userId, gridConfig.GridDataObject, gridConfig.GridDefinedColums, gridConfig.GridFilterCondition, gridConfig.GridSortCondition, gridConfig.FilterByValue, gridConfig.GridDataAction, gridConfig.StartRow, gridConfig.EndRow, gridConfig.OrderBy, gridConfig.OrderDirection, gridConfig.GridSumColums);
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
                    if(dr[col] == DBNull.Value)
                    {
                        row.Add(col.ColumnName, "");
                    }
                    else
                    {
                        row.Add(col.ColumnName, dr[col]);
                    }
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
                statement = string.Format("exec [dbo].[USP_System_Data_Function_Get] @UserId ={0}, @FunctionName = '{1}', @Parameter = N'{2}', @TextFilter = N'{3}', @Action = '{4}', @StartRow = {5}, @EndRow = {6}, @GlobalOrder = '{7}', @GlobalOrderDirection = {8}"
                    , userId, gridConfig.GridDataObject, gridConfig.GridParameters, gridConfig.FilterByValue, "count", gridConfig.StartRow, gridConfig.EndRow, gridConfig.OrderBy, gridConfig.OrderDirection);
            }
            else
            {
                statement = string.Format("exec [dbo].[USP_System_Data_List_Get] @UserId ={0}, @TableName = '{1}', @Colums = '{2}', @Condition = N'{3}', @OrderColums = '{4}', @TextFilter = N'{5}', @Action = '{6}', @StartRow = {7}, @EndRow = {8}, @GlobalOrder = '{9}', @GlobalOrderDirection = {10}"
                    , userId, gridConfig.GridDataObject, gridConfig.GridDefinedColums, gridConfig.GridFilterCondition, gridConfig.GridSortCondition, gridConfig.FilterByValue, "count", gridConfig.StartRow, gridConfig.EndRow, gridConfig.OrderBy, gridConfig.OrderDirection);
            }

            int result = dbFactory.GetContext().Database.SqlQuery<int>
                    (statement).FirstOrDefault();
            return result;
        }

        public Dictionary<string, object> SumDataFromConfiguration(int userId, GridViewConfig gridConfig)
        {
            gridConfig.GridDataAction = "sum";
            //gridConfig.FilterBy
            return GetDataFromConfigurationJsonable(userId, gridConfig).First();
        }

        #endregion

        #region Object
        public int SaveObject(int userId, string tableName, string objectData)
        {
            objectData = objectData.Replace("'", "''");
            string statement = string.Format("exec [dbo].[USP_System_Data_Update] @TableName = '{0}', @Data = N'{1}', @UserId = {2}"
                    , tableName, objectData, userId);
            
            int result = dbFactory.GetContext().Database.SqlQuery<int>
                    (statement).FirstOrDefault();
            return result;
        }

        public void SaveListObject(int userId, string tableName, string objectData)
        {
            objectData = objectData.Replace("'", "''");
            string statement = string.Format("exec [dbo].[USP_System_Data_BulkUpdate] @TableName = '{0}', @Data = N'{1}', @UserId = {2}"
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

        public void DeleteObject(int userId, string tableName, int keyValue, bool isHardDelete)
        {
            string statement = string.Format("exec [dbo].[USP_System_Data_Object_Delete] @UserId = {0}, @TableName = '{1}', @Value = {2}, @IsHardDelete = {3}"
                    , userId, tableName, keyValue, isHardDelete? "1" : "0");

            dbFactory.GetContext().Database.ExecuteSqlCommand(statement);
        }
        #endregion

        public bool CheckCanCreate(int userId, string tableName)
        {
            string statement = string.Format("select [dbo].[UFN_System_Check_Role_Object] ( {0}, '{1}', '{2}')",
                    userId, tableName, "update");

            bool result = dbFactory.GetContext().Database.SqlQuery<bool>
                    (statement).FirstOrDefault();
            return result;
        }
    }
}
