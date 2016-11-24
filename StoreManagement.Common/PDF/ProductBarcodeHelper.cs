using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iTextSharp.text;
using iTextSharp.text.pdf;

namespace StoreManagement.Common.PDF
{
    public class ProductBarcodeHelper
    {
        public static void CreatePDF(string path, List<iPDFItem> items, int rows, int cols, Rectangle pagesize = null)
        {
            var outputStream = new FileStream(path, FileMode.Create);
            CreatePDF(outputStream, items, rows, cols , pagesize);
        }

        public static void CreatePDF(Stream outputstream, List<iPDFItem> items, int rows, int cols, Rectangle pagesize = null)
        {
            var padding = 10;
            if (pagesize == null) pagesize = PageSize.A4;
 
            //==========================
            //config document
            Document document = new Document(pagesize, padding, padding, padding, padding);
            Rectangle size = document.PageSize;
            float width =  size.Width - 2 * padding;
            float height = size.Height - 2 * padding;

            //writer
            PdfWriter pdfWriter = PdfWriter.GetInstance(document, outputstream);
            document.Open();
            PdfContentByte pdfContentByte = pdfWriter.DirectContent;

            
            //=========================
            //calculate grid size
            float itemWidth = width / cols;
            float itemHeight = height / rows;

            //=========================
            //create table
            PdfPTable table = new PdfPTable(cols) { WidthPercentage = 100 };
            //table.DefaultCell.Border = Rectangle.NO_BORDER;
            table.DefaultCell.HorizontalAlignment = Element.ALIGN_CENTER;
            table.DefaultCell.VerticalAlignment = Element.ALIGN_MIDDLE;
            table.DefaultCell.FixedHeight = itemHeight;

            for (int i = 0; i < items.Count; i++)
            {
                //create stemp
                //var stemp = createTableItem(pdfContentByte, items[i] );

                //=====================
                //add celltable
                table.AddCell("chumano" + i);

            }
            document.Add(table);
            document.Close();
        }

        private static PdfPCell createTableItem(PdfContentByte pdfContentByte , iPDFItem item)
        {
            return item.Create(pdfContentByte);
        }

        //
        public static void CreateBarcode(string path)
        {
            //
            Document document = new Document(PageSize.A4, 50, 50, 50, 50);
            Rectangle size = document.PageSize;


            PdfWriter pdfWriter = PdfWriter.GetInstance(document, new FileStream(path, FileMode.Create));
            document.Open();

            PdfContentByte pdfContentByte = pdfWriter.DirectContent;

            // Barcode 128 EAN
            Image imageEan = BarcodeHelper.GetBarcode128(pdfContentByte, "3333333456", false, Barcode.EAN13);

            PdfPTable table = new PdfPTable(3) { WidthPercentage = 100 };
            //table.DefaultCell.Border = Rectangle.NO_BORDER;
            table.DefaultCell.HorizontalAlignment = Element.ALIGN_CENTER;
            table.DefaultCell.VerticalAlignment = Element.ALIGN_MIDDLE;
            //table.DefaultCell.FixedHeight = 70;

            for (int i = 0; i < 10; i++)
            {
                //barcode
                Phrase bc_ph = new Phrase(new Chunk(imageEan, 0, 0));

                //--------------
                PdfPTable stemp = new PdfPTable(1) { WidthPercentage = 100 };
                stemp.DefaultCell.HorizontalAlignment = Element.ALIGN_CENTER;
                stemp.DefaultCell.VerticalAlignment = Element.ALIGN_MIDDLE;

                //barcode cell
                var bc_cell = new PdfPCell(bc_ph);
                //bc_cell.Colspan = 1;
                stemp.AddCell(bc_ph);

                //price
                stemp.AddCell("400000");
                //name
                stemp.AddCell("ÁO SƠ MI NAM OWEN MÀU TÍM SỌC ĐỨNG Tím 42");

                //=====================
                //add celltable
                table.AddCell(stemp);

            }
            document.Add(table);
            document.Close();
        }

    }
}
