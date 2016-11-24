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

        public ProductPDFItem(string code, string name, double price)
        {
            this.Code = code;
            this.Name = name;
            this.Price = price;
        }

        public override PdfPCell Create(PdfContentByte pdfContentByte)
        {
            //barcode
            Image imageEan = BarcodeHelper.GetBarcode128(pdfContentByte, this.Code, false, Barcode.EAN13);
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
            stemp.AddCell(string.Format("{0} vnđ" , this.Price) );
            //name
            stemp.AddCell(this.Name.ToUpper());

            return new PdfPCell(stemp);
        }
    }
}
