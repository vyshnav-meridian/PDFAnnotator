## PDFAnnotator

PDFAnnotator is a plug-and-play iOS library that allows users to download, view, and annotate PDFs with ease. It handles the entire lifecycle of a PDF—from fetching a remote URL to saving the final annotated document.

## Features

* Internal Downloading: Simply provide a web URL; the package handles the background download and local caching.

* Drawing Tools: Smooth ink annotations with customizable colors and brush thickness.

* Undo Support: Easily step back through your annotations.

* Built-in Share Sheet: Share or save the final PDF directly from the UI.

* Multi-Platform Support: Available via CocoaPods and Swift Package Manager.

## Installation

CocoaPods

Add the following line to your Podfile:

pod 'PDFAnnotator'
Then run pod install.

Swift Package Manager

1. In Xcode, go to File > Add Packages...

2. Paste the repository URL: https://github.com/vyshnav-meridian/PDFAnnotator.git

3. Select version 1.0.2 or higher.

## Quick Start

Using `PDFAnnotator` is designed to be a one-liner. Use the `PDFAnnotatorFactory` to launch the controller:

```swift
import PDFAnnotator

// Inside your ViewController
PDFAnnotatorFactory.createAndDownload(
    from: url, 
    onPdfSaved: { path in 
        print("💾 Saved edited PDF at: \(path)") 
    }, 
    onClose: { [weak self] in 
        self?.dismiss(animated: true) 
    }, 
    onDownloadProgress: { message in 
        print("⏳ \(message)") 
    }, 
    completion: { [weak self] annotatorVC in 
        guard let vc = annotatorVC else { return }
        vc.modalPresentationStyle = .fullScreen
        self?.present(vc, animated: true)
    }
)
```

## Requirements

* **iOS**: 14.0 or higher
* **Swift**: 5.0 or higher
* **Xcode**: 12.0 or higher
  
## Author

Vyshnav P C 
Email: vyshnav@meridian.net.in

GitHub: vyshnav-meridian

## License

This project is licensed under the MIT License - see the LICENSE file for details.

