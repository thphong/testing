using DocumentFormat.OpenXml;
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

            var template = new FileInfo(fileName);
            byte[] templateBytes = File.ReadAllBytes(template.FullName);

            using (var templateStream = new MemoryStream())
            {
                templateStream.Write(templateBytes, 0, templateBytes.Length);
                using (var excelDoc = SpreadsheetDocument.Open(templateStream, true))
                {
                    WorkbookPart workbookPart = excelDoc.WorkbookPart;
                    SheetData sheetData = workbookPart.WorksheetParts.First().Worksheet.GetFirstChild<SheetData>();

                    string text;
                    object value;

                    SharedStringTablePart sstpart = workbookPart.GetPartsOfType<SharedStringTablePart>().First();
                    SharedStringTable sst = sstpart.SharedStringTable;

                    //Change value of object 
                    foreach (SharedStringItem item in sstpart.SharedStringTable.Elements<SharedStringItem>())
                    {
                        text = item.InnerText.ToString();
                        if (text.StartsWith("{{") && text.EndsWith("}}"))
                        {
                            text = text.Substring(2, text.Length - 4);
                            Text textItem = item.Descendants<Text>().First();
                            value = objectData[text];
                            if (value != null)
                            {
                                textItem.Text = value.ToString();
                            }
                        }
                    }

                    //Change value of list data
                    var rows = sheetData.Elements<Row>();
                    string baseColum = string.Empty;
                    uint baseRow = 0;
                    foreach (Row row in rows)
                    {
                        var cells = row.Elements<Cell>();
                        foreach (Cell cell in cells)
                        {
                            text = cell.InnerText;
                            if (!String.IsNullOrEmpty(text))
                            {
                                text = sst.ElementAt(int.Parse(text)).InnerText;
                                if (text.Equals("[[DataList]]"))
                                {
                                    baseColum = GetCoumn(cell.CellReference);
                                    baseRow = GetRow(cell.CellReference);
                                    break;
                                }
                            }
                        }
                        if (baseRow > 0)
                            break;
                    }

                    uint numRow = 0;
                    string runCoulm;
                    foreach (DataRow row in list.Rows)
                    {
                        runCoulm = baseColum;
                        for (int numCol = 0; numCol < list.Columns.Count; numCol++)
                        {
                            if (row[numCol] != DBNull.Value)
                            {
                                Cell cell = GetCell(sheetData, runCoulm, baseRow + numRow);
                                if (cell != null)
                                {
                                    cell.CellValue = new CellValue(row[numCol].ToString());
                                    if( row[numCol].GetType() == typeof(int) || row[numCol].GetType() == typeof(float)
                                        || row[numCol].GetType() == typeof(decimal))
                                    {
                                        cell.DataType = CellValues.Number;
                                    }
                                    else
                                    {
                                        cell.DataType = CellValues.String;
                                    }
                                    
                                }
                            }

                            runCoulm = AddCoumn(runCoulm);
                        }
                        numRow++;
                    }
                }
                templateStream.Position = 0;
                var result = templateStream.ToArray();
                templateStream.Flush();

                return result;
            }
        }
        private static string AddCoumn(string colum)
        {
            string result = "";
            int add = 1;
            for (int i = colum.Length - 1; i >= 0; i--)
            {
                if (colum[i] + add <= 'Z')
                {
                    result = (char)(colum[i] + add) + result;
                    add = 0;
                }
                else
                {
                    result = 'A' + result;
                }
            }
            if (add == 1)
                result = 'A' + result;
            return result;
        }

        private static string GetCoumn(string referenceCode)
        {
            string result = "";
            for (int i = 0; i < referenceCode.Length; i++)
            {
                if (referenceCode[i] >= '0' && referenceCode[i] <= '9')
                {
                    break;
                }
                result += referenceCode[i];
            }
            return result;
        }

        private static uint GetRow(string referenceCode)
        {
            string result = "";
            for (int i = 0; i < referenceCode.Length; i++)
            {
                if (referenceCode[i] >= '0' && referenceCode[i] <= '9')
                {
                    result += referenceCode[i];
                }
            }
            return uint.Parse(result);
        }

        private static Cell GetCell(SheetData sheetData, string columnName, uint rowIndex)
        {
            Row row = GetRow(sheetData, rowIndex);

            if (row == null)
                return null;

            return row.Elements<Cell>().Where(c => string.Compare
                      (c.CellReference.Value, columnName +
                      rowIndex, true) == 0).FirstOrDefault();
        }

        // Given a worksheet and a row index, return the row.
        private static Row GetRow(SheetData sheetData, uint rowIndex)
        {
            return sheetData.Elements<Row>().Where(r => r.RowIndex == rowIndex).FirstOrDefault();
        }
    }
}
