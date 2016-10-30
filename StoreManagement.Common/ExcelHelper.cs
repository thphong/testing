using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Excel = Microsoft.Office.Interop.Excel;

namespace StoreManagement.Common
{
    using System;
    using System.Collections.Generic;
    using System.Text;
    using System.Data.Common;
    using System.Data.OleDb;
    using System.Data;
    using System.IO;


    public class ExcelHelper
    {

        #region Get Excel
        //Get number of rows data in file
        public static Int64 NumberRows(string pathfile, string sheetname)
        {
            int num = 0;
            bool is2007 = false;
            if (IsExcelFile(pathfile, out is2007))
            {
                IExcelFile excelfile = null;
                if (is2007)
                    excelfile = new Excel2007(pathfile);
                else
                    excelfile = new Excel2003(pathfile);

                num = excelfile.GetNumberRows(sheetname);
            }
            return num;
        }

        //Get FirstSheetName
        public static string GetFirstSheetName(string pathfile)
        {
            string firstsheet = "";
            bool is2007 = false;
            if (IsExcelFile(pathfile, out is2007))
            {
                IExcelFile excelfile = null;
                if (is2007)
                    excelfile = new Excel2007(pathfile);
                else
                    excelfile = new Excel2003(pathfile);

                firstsheet = excelfile.GetFirstSheetName();
            }
            return firstsheet;
        }

        //Load Format of data in dataTable
        public static System.Data.DataTable LoadTableColumns(string pathfile)
        {
            System.Data.DataTable tbl = null;
            bool is2007 = false;
            if (IsExcelFile(pathfile, out is2007))
            {
                IExcelFile excelfile = null;
                if (is2007)
                    excelfile = new Excel2007(pathfile);
                else
                    excelfile = new Excel2003(pathfile);

                tbl = excelfile.GetDataTable_Format();
            }
            return tbl;
        }

        //Get DataSheet
        public static System.Data.DataTable LoadDataSheet(string pathfile, string sheetname)
        {
            System.Data.DataTable tbl = null;
            bool is2007 = false;
            if (IsExcelFile(pathfile, out is2007))
            {
                IExcelFile excelfile = null;
                if (is2007)
                    excelfile = new Excel2007(pathfile);
                else
                    excelfile = new Excel2003(pathfile);

                tbl = excelfile.GetDataTable_SheetName(sheetname);
            }
            return tbl;
        }

        //Get Data
        public static System.Data.DataTable LoadData(string pathfile)
        {
            System.Data.DataTable tbl = null;
            bool is2007 = false;
            if (IsExcelFile(pathfile, out is2007))
            {
                IExcelFile excelfile = null;
                if (is2007)
                    excelfile = new Excel2007(pathfile);
                else
                    excelfile = new Excel2003(pathfile);

                tbl = excelfile.GetDataTable();
            }
            return tbl;
        }

        //====================================================
        public static bool IsExcelFile(string filename, out bool isXLSX)
        {
            string ext = GetExtension(filename);
            ext = ext.ToUpper();
            isXLSX = false;
            if (ext == ".XLS" || ext == ".XLSX")
            {
                if (ext == ".XLSX") isXLSX = true;
                return true;
            }
            return false;
        }

        public static string GetExtension(string filename)
        {
            string ext = System.IO.Path.GetExtension(filename);
            return ext;
        }
        #endregion

        #region Create Excel
        //----------------------news--------------------------
        public static bool CreateExcel(string filename)
        {
            Excel.Application xlApp = null;
            Excel.Workbook xlWorkBook = null;
            Excel.Worksheet xlWorkSheet = null;
            object misValue = System.Reflection.Missing.Value;
            try
            {
                if (File.Exists(filename)) { File.Delete(filename); }


                xlApp = new Excel.Application();
                xlWorkBook = xlApp.Workbooks.Add(misValue);

                xlWorkSheet = (Excel.Worksheet)xlWorkBook.Worksheets.get_Item(1);
                //for (int i = 1; i <= names.Count; i++)
                //{
                //    xlWorkSheet.Cells[1, i] = names[i - 1];
                //}

                xlWorkBook.SaveAs(filename,
                    Excel.XlFileFormat.xlWorkbookNormal,
                    misValue, misValue, misValue, misValue,
                    Excel.XlSaveAsAccessMode.xlExclusive,
                    misValue, misValue, misValue, misValue, misValue);
                xlWorkBook.Close(true, misValue, misValue);
                xlApp.Quit();

                releaseObject(xlWorkSheet);
                releaseObject(xlWorkBook);
                releaseObject(xlApp);
            }
            catch (Exception e)
            {
                if (xlWorkBook != null) xlWorkBook.Close(true, misValue, misValue);
                if (xlApp != null) xlApp.Quit();

                releaseObject(xlWorkSheet);
                releaseObject(xlWorkBook);
                releaseObject(xlApp);

                return false;
            }

            return true;

        }

        public static bool CreateExcel(string filename, List<string> names)
        {
            Excel.Application xlApp = null;
            Excel.Workbook xlWorkBook = null;
            Excel.Worksheet xlWorkSheet = null;
            object misValue = System.Reflection.Missing.Value;
            try
            {
                if (File.Exists(filename)) { File.Delete(filename); }


                xlApp = new Excel.Application();
                xlWorkBook = xlApp.Workbooks.Add(misValue);

                xlWorkSheet = (Excel.Worksheet)xlWorkBook.Worksheets.get_Item(1);
                for (int i = 1; i <= names.Count; i++)
                {
                    xlWorkSheet.Cells[1, i] = names[i - 1];
                }

                xlWorkBook.SaveAs(filename,
                    Excel.XlFileFormat.xlWorkbookNormal,
                    misValue, misValue, misValue, misValue,
                    Excel.XlSaveAsAccessMode.xlExclusive,
                    misValue, misValue, misValue, misValue, misValue);
                xlWorkBook.Close(true, misValue, misValue);
                xlApp.Quit();

                releaseObject(xlWorkSheet);
                releaseObject(xlWorkBook);
                releaseObject(xlApp);
            }
            catch (Exception e)
            {
                if (xlWorkBook != null) xlWorkBook.Close(true, misValue, misValue);
                if (xlApp != null) xlApp.Quit();

                releaseObject(xlWorkSheet);
                releaseObject(xlWorkBook);
                releaseObject(xlApp);

                return false;
            }

            return true;

        }

        public static bool ImportNewRow(string filename, string[] values)
        {
            try
            {
                //@"Provider=Microsoft.ACE.OLEDB.12.0;Data Source='{0}';Extended Properties=Excel 8.0;"
                //@"provider=Microsoft.Jet.OLEDB.4.0;Data Source='{0}';Extended Properties=Excel 8.0"
                string conStr = string.Format(@"Provider=Microsoft.ACE.OLEDB.12.0;Data Source='{0}';Extended Properties=Excel 8.0;", filename);
                string xlsSheet = @"Sheet1$";

                OleDbConnection con = new OleDbConnection(conStr);
                con.Open();

                //InsertCommand.Connection = con;

                string sheetname = GetFirstSheetName(filename);
                OleDbDataAdapter adapter = new OleDbDataAdapter("Select * FROM [Sheet1$]", con);

                DataTable dt = new DataTable();
                adapter.Fill(dt);

                string cols = "";
                string vals = "";
                System.Data.DataRow newRow = dt.NewRow();
                for (int i = 0; i < values.Length; i++)
                {
                    //OleDbParameter par = InsertCommand.Parameters[i];
                    //par.Value = values[i];

                    if (cols != "") cols += ",";
                    cols += "[" + dt.Columns[i].ColumnName + "]";//par.SourceColumn;

                    if (vals != "") vals += ",";
                    vals += "'" + values[i] + "'";
                    //--------------
                    newRow[i] = values[i];
                }

                dt.Rows.Add(newRow);

                dt.AcceptChanges();
                string str = "Insert into [" + xlsSheet + "] (" + cols + ") VALUES (" + vals + ")";
                //InsertCommand.CommandText =str;
                //adapter.InsertCommand = InsertCommand;
                //adapter.InsertCommand.Connection = con;

                //adapter.Update(dt);
                //InsertCommand.ExecuteNonQuery();
                OleDbDataAdapter dbadapter = new OleDbDataAdapter(str, con);
                dbadapter.SelectCommand.ExecuteNonQuery();
                dbadapter.Dispose();
                //OleDbCommand cmd = new OleDbCommand(str);

                //cmd.Connection = con;
                //cmd.ExecuteNonQuery();
                con.Close();

            }
            catch (Exception e)
            {
                return false;
            }

            return true;
        }

        public static bool CreateExcel(string filename, DataTable tbl, Func<int, int> proccess)
        {
            Excel.Application xlApp = null;
            Excel.Workbook xlWorkBook = null;
            Excel.Worksheet xlWorkSheet = null;
            object misValue = System.Reflection.Missing.Value;
            try
            {
                if (File.Exists(filename)) { File.Delete(filename); }


                xlApp = new Excel.Application();
                xlWorkBook = xlApp.Workbooks.Add(misValue);

                xlWorkSheet = (Excel.Worksheet)xlWorkBook.Worksheets.get_Item(1);
                //====================================================
                //header name
                for (int i = 1; i <= tbl.Columns.Count; i++)
                {
                    xlWorkSheet.Cells[1, i] = tbl.Columns[i - 1].ColumnName;
                }

                //body data
                int rowindex = 2;
                foreach (DataRow row in tbl.Rows)
                {
                    for (int i = 1; i <= tbl.Columns.Count; i++)
                    {
                        xlWorkSheet.Cells[(rowindex), i] = row[i - 1].ToString();
                    }
                    rowindex++;
                    proccess(rowindex);
                }


                //=====================================================
                xlWorkBook.SaveAs(filename,
                    Excel.XlFileFormat.xlWorkbookNormal,
                    misValue, misValue, misValue, misValue,
                    Excel.XlSaveAsAccessMode.xlExclusive,
                    misValue, misValue, misValue, misValue, misValue);
                xlWorkBook.Close(true, misValue, misValue);
                xlApp.Quit();

                releaseObject(xlWorkSheet);
                releaseObject(xlWorkBook);
                releaseObject(xlApp);
            }
            catch (Exception e)
            {
                if (xlWorkBook != null) xlWorkBook.Close(true, misValue, misValue);
                if (xlApp != null) xlApp.Quit();

                releaseObject(xlWorkSheet);
                releaseObject(xlWorkBook);
                releaseObject(xlApp);

                return false;
            }

            return true;
        }

        private static void releaseObject(object obj)
        {
            try
            {
                System.Runtime.InteropServices.Marshal.ReleaseComObject(obj);
                obj = null;
            }
            catch (Exception ex)
            {
                obj = null;
            }
            finally
            {
                GC.Collect();
            }
        }
        #endregion
    }

    public interface IExcelFile
    {
        string GetFirstSheetName();
        int GetNumberRows(string sheetname);

        DataTable GetDataTable();
        DataTable GetDataTable_SheetName(string sheetname);
        DataTable GetDataTable_Command(string commandText);

        DataTable GetDataTable_Format();
    }

    public class BaseExcelFile
    {
        public string PathFile { get; set; }
        public string ConnectionStringPattern { get; set; }
        public BaseExcelFile(string pathfile)
        {
            this.PathFile = pathfile;
        }

        public string GetConnectionString()
        {
            return string.Format(ConnectionStringPattern, PathFile);
        }

    }

    public class Excel2003 : BaseExcelFile, IExcelFile
    {
        public Excel2003(string pathfile)
            : base(pathfile)
        {
            this.ConnectionStringPattern = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source={0};Extended Properties='Excel 8.0;HDR=Yes;IMEX=1'";
        }

        public string GetFirstSheetName()
        {
            string sheetname = "";
            OleDbConnection ExcelConection = new OleDbConnection();
            try
            {
                ExcelConection.ConnectionString = GetConnectionString();
                ExcelConection.Open();
                //lay cac sheetname
                System.Data.DataTable dt = ExcelConection.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
                if (dt != null)
                {
                    //lay first sheet name
                    sheetname = dt.Rows[0]["TABLE_NAME"].ToString();
                }
            }
            catch (Exception e)
            { }
            finally
            { ExcelConection.Close(); }
            return sheetname;
        }

        public int GetNumberRows(string sheetname)
        {
            string commandText = string.Format(@"SELECT COUNT(*) FROM [{0}]", sheetname);
            //========================================
            DataTable tbl = GetDataTable_Command(commandText);
            int num = 0;
            if (tbl != null)
                num = Convert.ToInt32(tbl.Rows[0][0]);
            return num;
        }

        public DataTable GetDataTable()
        {
            string sheetname = GetFirstSheetName();
            string commandText = string.Format(@"SELECT * FROM [{0}]", sheetname);
            //========================================
            return GetDataTable_Command(commandText);
        }
        public DataTable GetDataTable_SheetName(string sheetname)
        {
            string commandText = string.Format(@"SELECT * FROM [{0}]", sheetname);
            //========================================
            return GetDataTable_Command(commandText);
        }

        public DataTable GetDataTable_Format()
        {
            string sheetname = GetFirstSheetName();
            string commandText = string.Format(@"SELECT TOP 1 * FROM [{0}]", sheetname);
            //========================================
            return GetDataTable_Command(commandText);
        }

        //==============================
        public DataTable GetDataTable_Command(string commandText)
        {
            //----------------------------------------------
            OleDbConnection ExcelConection = null;
            DbProviderFactory dbFactories = DbProviderFactories.GetFactory("System.Data.OleDb");
            DbConnection m_Conn = dbFactories.CreateConnection();

            try
            {
                //------------------------------------------
                m_Conn.ConnectionString = GetConnectionString();
                DbDataAdapter adapter = dbFactories.CreateDataAdapter();
                DbCommand selectCommand = m_Conn.CreateCommand();
                selectCommand.CommandText = commandText;
                selectCommand.Connection = m_Conn;
                System.Data.DataSet datum = new System.Data.DataSet();

                m_Conn.Open();
                adapter.SelectCommand = selectCommand;
                adapter.Fill(datum);

                return datum.Tables[0];

            }
            catch (Exception Args)
            {
                return null;
            }
            finally
            {
                if (ExcelConection != null)
                    ExcelConection.Dispose();
                ////////////////
                if (m_Conn != null)
                    m_Conn.Close();
            }
        }


    }
    
    public class Excel2007 : BaseExcelFile, IExcelFile
    {
        public Excel2007(string pathfile)
            : base(pathfile)
        {
            this.ConnectionStringPattern = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source={0};Extended Properties=\"Excel 12.0;HDR=Yes;IMEX=1\";";
        }

        public int GetNumberRows(string sheetname)
        {
            string commandText = string.Format(@"SELECT COUNT(*) FROM [{0}]", sheetname);
            //========================================
            DataTable tbl = GetDataTable_Command(commandText);
            int num = 0;
            if (tbl != null)
                num = Convert.ToInt32(tbl.Rows[0][0]);
            return num;
        }

        public string GetFirstSheetName()
        {
            string sheetname = "";
            OleDbConnection ExcelConection = new OleDbConnection();
            try
            {
                ExcelConection.ConnectionString = GetConnectionString();
                ExcelConection.Open();
                //lay cac sheetname
                System.Data.DataTable dt = ExcelConection.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
                if (dt != null)
                {
                    //lay first sheet name
                    sheetname = dt.Rows[0]["TABLE_NAME"].ToString();
                    if (sheetname.Contains("FilterDatabase"))
                    {
                        sheetname = dt.Rows[1]["TABLE_NAME"].ToString();
                    }
                }
            }
            catch (Exception e)
            { }
            finally
            {
                ExcelConection.Close();
            }
            return sheetname;
        }

        public DataTable GetDataTable()
        {
            string sheetname = GetFirstSheetName();
            string commandText = string.Format(@"SELECT * FROM [{0}]", sheetname);
            //========================================
            return GetDataTable_Command(commandText);
        }
        public DataTable GetDataTable_SheetName(string sheetname)
        {
            string commandText = string.Format(@"SELECT * FROM [{0}]", sheetname);
            //========================================
            return GetDataTable_Command(commandText);
        }

        public DataTable GetDataTable_Format()
        {
            string sheetname = GetFirstSheetName();
            string commandText = string.Format(@"SELECT TOP 1 * FROM [{0}]", sheetname);
            //========================================
            return GetDataTable_Command(commandText);
        }

        //==============================
        public DataTable GetDataTable_Command(string commandText)
        {
            //----------------------------------------------
            string connectionString = string.Empty;
            DbProviderFactory dbFactories = DbProviderFactories.GetFactory("System.Data.OleDb");
            DbConnection m_Conn;

            m_Conn = dbFactories.CreateConnection();
            connectionString = GetConnectionString();
            m_Conn.ConnectionString = connectionString;

            DbDataAdapter adapter = dbFactories.CreateDataAdapter();
            DbCommand selectCommand = m_Conn.CreateCommand();
            selectCommand.CommandText = commandText;
            selectCommand.Connection = m_Conn;
            System.Data.DataSet datum = new System.Data.DataSet();
            try
            {
                m_Conn.Open();
                adapter.SelectCommand = selectCommand;
                adapter.Fill(datum);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                m_Conn.Close();
            }

            return datum.Tables[0];
        }


    }

}
