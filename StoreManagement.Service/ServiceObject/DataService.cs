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

        public Dictionary<string, object> Login(string loginId, string password)
        {
            string statement = string.Format("exec [dbo].[USP_System_Login] @Login = '{0}', @Password = '{1}'", loginId, password);
            
            DataSet retVal = new DataSet();
            SqlConnection sqlConn = (SqlConnection)dbFactory.GetContext().Database.Connection;
            SqlCommand cmdReport = new SqlCommand(statement, sqlConn);
            SqlDataAdapter daReport = new SqlDataAdapter(cmdReport);
            using (cmdReport)
            {
                cmdReport.CommandType = CommandType.Text;
                daReport.Fill(retVal);
            }
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

        public void Logout(int userId)
        {
            string statement = string.Format("exec [dbo].[USP_System_Logout] @UserId = {0}", userId);

            dbFactory.GetContext().Database.SqlQuery<int>(statement).FirstOrDefault();
        }

        public Dictionary<string, object> Register(string name, string username, string email, string password,
           string storename, string phone, string address, string city, int productgroup)
        {
            string statement = string.Format(@"exec [dbo].[USP_System_Register] 
                        @name = N'{0}', @username = N'{1}', @mail = N'{2}' , @password = N'{3}', 
                        @storename = N'{4}',@phone = N'{5}',@address = N'{6}',@city = N'{7}',@productgroup={8}
                        ",
                        name, username, email, password,
                        storename, phone, address, city, productgroup);

            DataSet retVal = new DataSet();
            SqlConnection sqlConn = (SqlConnection)dbFactory.GetContext().Database.Connection;
            SqlCommand cmdReport = new SqlCommand(statement, sqlConn);
            SqlDataAdapter daReport = new SqlDataAdapter(cmdReport);
            using (cmdReport)
            {
                cmdReport.CommandType = CommandType.Text;
                daReport.Fill(retVal);
            }
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

        public int SaveComplexObject(int userId, string tableName, string objectData, string subTableName, string subObjectData, string associatedColumn = "")
        {
            objectData = objectData.Replace("'", "''");
            subObjectData = subObjectData.Replace("'", "''");
            string statement = string.Format("exec [dbo].[USP_System_Data_ComplexObject_Update] @TableName = '{0}', @Data = N'{1}', @SubTableName = '{2}', @DataList = N'{3}', @UserId = {4}, @AssociatedColumn = '{5}'"
                    , tableName, objectData, subTableName, subObjectData, userId, associatedColumn);

            int result = dbFactory.GetContext().Database.SqlQuery<int>
                    (statement).FirstOrDefault();
            return result;
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

        public bool CheckField(int userId, string field)
        {
            string statement = string.Format("select [dbo].[UFN_System_Check_Role_Field] ( {0}, '{1}')",
                    userId, field);

            bool result = dbFactory.GetContext().Database.SqlQuery<bool>
                    (statement).FirstOrDefault();
            return result;
        }

        public Dictionary<string, object> GetRules(int userId, GridViewConfig gridConfig)
        {
            DataTable dt = GetDataFromConfiguration(userId, gridConfig);
            Dictionary<string, object> result = new Dictionary<string, object>();
            foreach (DataRow dr in dt.Rows)
            {
                result.Add(dr["RuleName"].ToString(), dr["Value"]);
            }
            return result;
        }

        public IList<Dictionary<string, object>> ExecuteSQL(int userId, string sql)
        {
            List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();
            DataTable dt;

            DataSet retVal = new DataSet();
            SqlConnection sqlConn = (SqlConnection)dbFactory.GetContext().Database.Connection;
            SqlCommand cmdReport = new SqlCommand(sql, sqlConn);
            SqlDataAdapter daReport = new SqlDataAdapter(cmdReport);
            using (cmdReport)
            {
                cmdReport.CommandType = CommandType.Text;
                daReport.Fill(retVal);
            }
            if (retVal.Tables.Count > 0)
            {
                dt = retVal.Tables[0];

                Dictionary<string, object> row;
                foreach (DataRow dr in dt.Rows)
                {
                    row = new Dictionary<string, object>();
                    foreach (DataColumn col in dt.Columns)
                    {
                        if (dr[col] == DBNull.Value)
                        {
                            row.Add(col.ColumnName, "");
                        }
                        else
                        {
                            if (dr[col] is DateTime)
                            {
                                row.Add(col.ColumnName, ((DateTime)dr[col]).ToString("yyyy-MM-dd hh:mm:ss"));
                            }
                            else
                            {
                                row.Add(col.ColumnName, dr[col]);
                            }
                        }
                    }
                    rows.Add(row);
                }
            }
            else
            {
                Dictionary<string, object> row = new Dictionary<string, object>();
                row.Add("Result", "SQL được thực thi thành công!");
                rows.Add(row);
            }
            
            return rows;
        }

        public  DataTable ImportExcel(DataTable data, string dbtable,
            int userid,
            int storeid,
            string session)
        {
            DataTable error = null;

            //--------------------
            SqlConnection sqlConn = (SqlConnection)dbFactory.GetContext().Database.Connection;
            sqlConn.Open();
            SqlTransaction trans = sqlConn.BeginTransaction();
            try
            {
                List<string> cols = new List<string>();
                cols.AddRange(new List<string>(){"[UserId]","[StoreId]","[Session]"});
                foreach (DataColumn col in data.Columns)
                {
                    cols.Add("[" + col.ColumnName + "]");
                }
                string colstr = string.Join(",", cols);

                //=====================
                string insertSql = "INSERT INTO {0}({1}) VALUES({2});";
                foreach (DataRow row in data.Rows)
                {
                    List<string> vals = new List<string>();
                    vals.AddRange(new List<string>() { userid.ToString(), storeid.ToString(), "'" + session + "'" });
                    foreach (DataColumn col in data.Columns)
                    {
                        string val = row[col.ColumnName].ToString();
                        vals.Add("N'" + val + "'");
                    }
                    string valstr = string.Join(",", vals);
                    //============================
                    string sql = string.Format(insertSql, dbtable, colstr, valstr);
                    SqlCommand cmd = new SqlCommand(sql, sqlConn,trans);
                    cmd.ExecuteNonQuery();
                }

                //=====================
                //insert to real table
                using (SqlCommand cmd = new SqlCommand("USP_System_ImportExcelData", sqlConn, trans))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@UserId", SqlDbType.Int).Value = userid;
                    cmd.Parameters.Add("@Template", SqlDbType.VarChar).Value = dbtable;
                    cmd.Parameters.Add("@Session", SqlDbType.VarChar).Value = session;

                    //===============
                    SqlDataAdapter dataAdapter = new SqlDataAdapter(cmd);
                    DataSet retVal = new DataSet();
                    dataAdapter.Fill(retVal);
                    if (retVal.Tables.Count > 0)
                    {
                        error = retVal.Tables[0];
                    }
                }

                trans.Commit();
            }
            catch (Exception ex)
            {
                trans.Rollback();
                throw new Exception("Không thể import data : " + dbtable +". " + ex.Message);
            }
            finally
            {
                sqlConn.Close();
            }

            return error;
        }
    }
}
