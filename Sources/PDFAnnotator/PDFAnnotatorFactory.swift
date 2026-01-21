import UIKit

public class PDFAnnotatorFactory {
    
    // Existing method for local file URLs
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
    
    // New method for remote URLs with download handling
    public static func createAndDownload(
        from remoteUrl: URL,
        onPdfSaved: ((String) -> Void)? = nil,
        onClose: (() -> Void)? = nil,
        onDownloadProgress: ((String) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        completion: @escaping (PDFAnnotatorViewController?) -> Void
    ) {
        onDownloadProgress?("Downloading PDF...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: remoteUrl)
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("downloaded_\(UUID().uuidString).pdf")
                try data.write(to: tempURL)
                
                DispatchQueue.main.async {
                    onDownloadProgress?("Download complete!")
                    let controller = create(
                        pdfUrl: tempURL,
                        onPdfSaved: onPdfSaved,
                        onClose: onClose
                    )
                    completion(controller)
                }
            } catch {
                DispatchQueue.main.async {
                    onError?(error)
                    completion(nil)
                }
            }
        }
    }
}
