using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iTextSharp.text;
using iTextSharp.text.pdf;

namespace StoreManagement.Common.PDF
{
    public class ProductPDFItem : BasePDFItem
    {
        public string Code { get; set; }
        public string Name { get; set; }
        public double Price { get; set; }

        public bool IsShowProductName { get; set; }
        public bool IsShowPrice { get; set; }


        public ProductPDFItem(string code, string name, double price)
        {
            this.Code = code;
            this.Name = name;
            this.Price = price;
        }

        public override PdfPCell Create(PdfContentByte pdfContentByte, float width , float height)
        {
            //setup font
            BaseFont baseFont = BaseFont.CreateFont(BaseFont.TIMES_BOLD, BaseFont.WINANSI, BaseFont.NOT_EMBEDDED);
            float fontsize = 6;
            float errorSize = 12;
            if (pdfContentByte.PdfDocument.PageSize.Height <=40)
            {
                errorSize = 6;
                fontsize = 4;
            }

            Font bfPrice = new Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, fontsize, Font.BOLD, BaseColor.BLACK);
            Font bfName = new Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, fontsize, Font.BOLD, BaseColor.BLACK);
            bfPrice = new Font(baseFont, fontsize);
            bfName = new Font(baseFont, fontsize);

            string priceStr =string.Format("GIA : {0:n0} VND", this.Price);
            string nameStr = CommonHelper.ConvertToUnsign1(this.Name.ToUpper());
            Phrase price = new Phrase(new Chunk(priceStr, bfPrice));
            Phrase name = new Phrase(new Chunk(nameStr, bfName));


            float w1 = baseFont.GetWidthPoint(priceStr, fontsize);
            float h1 = baseFont.GetAscentPoint(priceStr, fontsize)
                - baseFont.GetDescentPoint(priceStr, fontsize);

            float w2 = baseFont.GetWidthPoint(nameStr, fontsize);
            float h2 = baseFont.GetAscentPoint(nameStr, fontsize)
                - baseFont.GetDescentPoint(nameStr, 8);

            PdfPCell cprice = new PdfPCell(price);
            //cprice.FixedHeight = 10;
            cprice.Border = Rectangle.NO_BORDER;
            cprice.HorizontalAlignment = Element.ALIGN_CENTER;
            cprice.VerticalAlignment = Element.ALIGN_TOP;
            cprice.Padding = 0;

            PdfPCell cname = new PdfPCell(name);
            //cname.FixedHeight = 10;
            cname.Border = Rectangle.NO_BORDER;
            cname.HorizontalAlignment = Element.ALIGN_CENTER;
            cname.VerticalAlignment = Element.ALIGN_TOP;
            cname.Padding = 0;

            float widthBarcode = width;
            float heightBarcode = height - errorSize;
            if (IsShowPrice) heightBarcode -= h1;
            if (IsShowProductName) heightBarcode -= h2;
            //=========================
            //barcode
            Image imageEan = BarcodeHelper.GetBarcode128(pdfContentByte, this.Code, false, Barcode.EAN13);
            
            var oldHeight = imageEan.Height;
            var scale = heightBarcode / oldHeight;
            //imageEan.ScaleAbsolute(widthBarcode, heightBarcode);
            imageEan.ScalePercent(scale*100);
            imageEan.ScaleToFitHeight = false;

            //--------------
            PdfPTable stemp = new PdfPTable(1) { WidthPercentage = 100 };
            //stemp.DefaultCell.Border = Rectangle.NO_BORDER;
            stemp.DefaultCell.HorizontalAlignment = Element.ALIGN_CENTER;
            stemp.DefaultCell.VerticalAlignment = Element.ALIGN_TOP;
            //stemp.DefaultCell.FixedHeight = heightBarcode;
            //=============================
            //barcode cell
            var bc_cell = new PdfPCell(imageEan);
            bc_cell.FixedHeight = heightBarcode;
            bc_cell.Border = Rectangle.NO_BORDER;
            bc_cell.HorizontalAlignment = Element.ALIGN_CENTER;
            bc_cell.VerticalAlignment = Element.ALIGN_TOP;
            bc_cell.Padding = 0;
            stemp.AddCell(bc_cell);

            //price         
            
            if (IsShowPrice) stemp.AddCell(cprice);
            
            //name
            
            if (IsShowProductName) stemp.AddCell(cname);

            var itemcell = new PdfPCell(stemp);
            return itemcell;
        }
    }
}
