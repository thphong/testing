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

            Font bfPrice = new Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 8, Font.BOLD, BaseColor.BLACK);
            Font bfName = new Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 8, Font.BOLD, BaseColor.BLACK);
            bfPrice = new Font(baseFont, 8);
            bfName = new Font(baseFont, 8);

            string priceStr =string.Format("GIA : {0:n} VND", this.Price).ToUpper();
            string nameStr = CommonHelper.ConvertToUnsign1(this.Name.ToUpper());
            Phrase price = new Phrase(new Chunk(priceStr, bfPrice));
            Phrase name = new Phrase(new Chunk(nameStr, bfName));

            
            float w1 = baseFont.GetWidthPoint(priceStr, 8);
            float h1 = baseFont.GetAscentPoint(priceStr, 8)
                - baseFont.GetDescentPoint(priceStr, 8);

            float w2 = baseFont.GetWidthPoint(nameStr, 8);
            float h2 = baseFont.GetAscentPoint(nameStr, 8)
                - baseFont.GetDescentPoint(nameStr, 8);

            PdfPCell cprice = new PdfPCell(price);
            cprice.FixedHeight = 10;
            cprice.Border = Rectangle.NO_BORDER;
            PdfPCell cname = new PdfPCell(name);
            cname.FixedHeight = 10;
            cname.Border = Rectangle.NO_BORDER;

            float widthBarcode = width;
            float heightBarcode = height ;
            if (IsShowPrice) heightBarcode -= cprice.FixedHeight;
            if (IsShowProductName) heightBarcode -= cname.FixedHeight;
            //=========================
            //barcode
            Image imageEan = BarcodeHelper.GetBarcode128(pdfContentByte, this.Code, false, Barcode.EAN13);
            Rectangle rect = imageEan.GetRectangle(0,0);
            imageEan.ScaleAbsolute(widthBarcode, 20);
            //imageEan.ScaleToFitHeight = false;
            //Phrase bc_ph = new Phrase(new Chunk(imageEan, 0, 0));

            //--------------
            PdfPTable stemp = new PdfPTable(1) { WidthPercentage = 100 };
            stemp.DefaultCell.Border = Rectangle.NO_BORDER;
            stemp.DefaultCell.HorizontalAlignment = Element.ALIGN_CENTER;
            stemp.DefaultCell.VerticalAlignment = Element.ALIGN_MIDDLE;
            //stemp.DefaultCell.FixedHeight = heightBarcode;
            //barcode cell
            var bc_cell = new PdfPCell(imageEan);
            //bc_cell.FixedHeight = heightBarcode;
            stemp.AddCell(bc_cell);

            //price         
            
            if (IsShowPrice) stemp.AddCell(cprice);
            
            //name
            
            if (IsShowProductName) stemp.AddCell(cname);

            var itemcell = new PdfPCell(stemp);
            itemcell.Border = Rectangle.NO_BORDER;
            return itemcell;
        }
    }
}
