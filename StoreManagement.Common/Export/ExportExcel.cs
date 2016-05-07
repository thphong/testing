using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoreManagement.Common.Export
{
    public class ExportExcel
    {
        public static byte[] ExportToCSVFileOpenXML(DataTable dt)
        {
            DataSet ds = new DataSet();
            DataTable dtCopy = new DataTable();
            dtCopy = dt.Copy();
            ds.Tables.Add(dtCopy);
            try
            {
                byte[] returnBytes = null;
                MemoryStream mem = new MemoryStream();
                var workbook = SpreadsheetDocument.Create(mem, DocumentFormat.OpenXml.SpreadsheetDocumentType.Workbook);
                {
                    var workbookPart = workbook.AddWorkbookPart();
                    workbook.WorkbookPart.Workbook = new DocumentFormat.OpenXml.Spreadsheet.Workbook();
                    workbook.WorkbookPart.Workbook.Sheets = new DocumentFormat.OpenXml.Spreadsheet.Sheets();
                    foreach (System.Data.DataTable table in ds.Tables)
                    {
                        var sheetPart = workbook.WorkbookPart.AddNewPart<WorksheetPart>();
                        var sheetData = new DocumentFormat.OpenXml.Spreadsheet.SheetData();
                        sheetPart.Worksheet = new DocumentFormat.OpenXml.Spreadsheet.Worksheet(sheetData);

                        DocumentFormat.OpenXml.Spreadsheet.Sheets sheets = workbook.WorkbookPart.Workbook.GetFirstChild<DocumentFormat.OpenXml.Spreadsheet.Sheets>();
                        string relationshipId = workbook.WorkbookPart.GetIdOfPart(sheetPart);

                        uint sheetId = 1;
                        if (sheets.Elements<DocumentFormat.OpenXml.Spreadsheet.Sheet>().Count() > 0)
                        {
                            sheetId =
                                sheets.Elements<DocumentFormat.OpenXml.Spreadsheet.Sheet>().Select(s => s.SheetId.Value).Max() + 1;
                        }

                        DocumentFormat.OpenXml.Spreadsheet.Sheet sheet = new DocumentFormat.OpenXml.Spreadsheet.Sheet() { Id = relationshipId, SheetId = sheetId, Name = table.TableName };
                        sheets.Append(sheet);

                        DocumentFormat.OpenXml.Spreadsheet.Row headerRow = new DocumentFormat.OpenXml.Spreadsheet.Row();

                        List<String> columns = new List<string>();
                        foreach (System.Data.DataColumn column in table.Columns)
                        {
                            columns.Add(column.ColumnName);

                            DocumentFormat.OpenXml.Spreadsheet.Cell cell = new DocumentFormat.OpenXml.Spreadsheet.Cell();
                            cell.DataType = DocumentFormat.OpenXml.Spreadsheet.CellValues.String;
                            cell.CellValue = new DocumentFormat.OpenXml.Spreadsheet.CellValue(column.ColumnName);
                            headerRow.AppendChild(cell);
                        }


                        sheetData.AppendChild(headerRow);

                        foreach (System.Data.DataRow dsrow in table.Rows)
                        {
                            DocumentFormat.OpenXml.Spreadsheet.Row newRow = new DocumentFormat.OpenXml.Spreadsheet.Row();
                            foreach (String col in columns)
                            {
                                DocumentFormat.OpenXml.Spreadsheet.Cell cell = new DocumentFormat.OpenXml.Spreadsheet.Cell();
                                cell.DataType = DocumentFormat.OpenXml.Spreadsheet.CellValues.String;
                                cell.CellValue = new DocumentFormat.OpenXml.Spreadsheet.CellValue(dsrow[col].ToString()); //
                                newRow.AppendChild(cell);
                            }

                            sheetData.AppendChild(newRow);
                        }

                    }
                }
                workbook.WorkbookPart.Workbook.Save();
                workbook.Close();

                returnBytes = mem.ToArray();

                return returnBytes;
            }
            catch (Exception)
            {

                throw;
            }
        }

        public static byte[] ExportFromTempalte(string tempalteFile, Dictionary<string, object> objectData, DataTable list)
        {
            string fileName = tempalteFile;

            /*using (var document = SpreadsheetDocument.Open(fileName, false))
            {
                var workbookPart = document.WorkbookPart;
                var workbook = workbookPart.Workbook;

                var sheets = workbook.Descendants<Sheet>();
                foreach (var sheet in sheets)
                {
                    var worksheetPart = (WorksheetPart)workbookPart.GetPartById(sheet.Id);

                    SharedStringTablePart sstpart = workbookPart.GetPartsOfType<SharedStringTablePart>().First();
                    SharedStringTable sst = sstpart.SharedStringTable;
                    
                    var rows = worksheetPart.Worksheet.Descendants<Row>();
                    foreach (var row in rows)
                    {
                        Console.WriteLine();
                        int count = row.Elements<Cell>().Count();

                        foreach (Cell c in row.Elements<Cell>())
                        {
                            int ssid = int.Parse(c.CellValue.Text);
                            string str = sst.ChildElements[ssid].InnerText;
                            
                        }
                    }
                }
            }*/

            using (FileStream fs = new FileStream(fileName, FileMode.Open, FileAccess.ReadWrite, FileShare.ReadWrite))
            {
                using (SpreadsheetDocument doc = SpreadsheetDocument.Open(fs, true))
                {
                    WorkbookPart workbookPart = doc.WorkbookPart;
                    SharedStringTablePart sstpart = workbookPart.GetPartsOfType<SharedStringTablePart>().First();
                    SharedStringTable sst = sstpart.SharedStringTable;

                    // Iterate through all the items in the SharedStringTable. If the text already exists, return its index.
                    foreach (SharedStringItem item in sstpart.SharedStringTable.Elements<SharedStringItem>())
                    {
                        if (item.InnerText != "" && item.InnerText.ToString().Contains("d"))
                        {
                            Text text2 = item.Descendants<Text>().First();
                            text2.Text = DateTime.Now.ToString();
                        }
                    }
                    sstpart.SharedStringTable.Save();
                }
            }

            return null;
        }

    }
}
