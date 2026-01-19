import UIKit

public class PDFAnnotatorFactory {
    
    public static func create(
        pdfUrl: URL,
        onPdfSaved: ((String) -> Void)? = nil,
        onClose: (() -> Void)? = nil
    ) -> PDFAnnotatorViewController {
        let controller = PDFAnnotatorViewController()
        controller.pdfUrl = pdfUrl
        controller.onPdfSaved = onPdfSaved
        controller.onClose = onClose
        return controller
    }
}
