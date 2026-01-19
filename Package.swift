// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PDFAnnotator",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "PDFAnnotator",
            targets: ["PDFAnnotator"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PDFAnnotator",
            dependencies: []),
        .testTarget(
            name: "PDFAnnotatorTests",
            dependencies: ["PDFAnnotator"]),
    ]
)
