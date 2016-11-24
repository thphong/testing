using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iTextSharp.text;
using iTextSharp.text.pdf;

namespace StoreManagement.Common.PDF
{
    public class BasePDFItem : iPDFItem
    {
        public virtual PdfPCell Create(PdfContentByte pdfContentByte)
        {
            return new PdfPCell(new Phrase("BaseItem"));
        }
    }

    public interface iPDFItem
    {
        PdfPCell Create(PdfContentByte pdfContentByte);
    }
}
