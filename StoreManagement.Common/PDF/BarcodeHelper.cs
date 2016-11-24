using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iTextSharp.text;
using iTextSharp.text.pdf;

namespace StoreManagement.Common.PDF
{
    public class BarcodeHelper
    {
        /// <summary>
        /// Gets the barcode39.
        /// </summary>
        /// <param name="pdfContentByte">The PDF content byte.</param>
        /// <param name="code">The code.</param>
        /// <param name="extended">if set to <c>true</c> [extended].</param>
        /// <returns>Barcode image.</returns>
        public static Image GetBarcode39(PdfContentByte pdfContentByte, string code, bool extended)
        {
            Barcode39 barcode39 = new Barcode39 { Code = code, StartStopText = false, Extended = extended };
            return barcode39.CreateImageWithBarcode(pdfContentByte, null, null);
        }

        /// <summary>
        /// Gets the barcode128.
        /// </summary>
        /// <param name="pdfContentByte">The PDF content byte.</param>
        /// <param name="code">The code.</param>
        /// <param name="extended">if set to <c>true</c> [extended].</param>
        /// <param name="codeType">Type of the code.</param>
        /// <returns>Barcode image.</returns>
        public static Image GetBarcode128(PdfContentByte pdfContentByte, string code, bool extended, int codeType)
        {
            Barcode128 code128 = new Barcode128 { Code = code, Extended = extended, CodeType = codeType };
            return code128.CreateImageWithBarcode(pdfContentByte, null, null);
        }


        public static Image GetBarcode128(PdfContentByte pdfContentByte, string code)
        {
            Barcode128 code128 = new Barcode128 { Code = code, Extended = false, CodeType = Barcode.EAN13 }; //Barcode.CODE128
            return code128.CreateImageWithBarcode(pdfContentByte, null, null);
        }
    }
}
