import UIKit
import PDFKit

public class PDFAnnotatorViewController: UIViewController, UIGestureRecognizerDelegate {

    // Public API for SDK integration
    public var pdfUrl: URL?
    public var onPdfSaved: ((String) -> Void)?
    public var onClose: (() -> Void)?

    private var pdfView: PDFView!
    private var topBar: UIView!
    private var drawButton: UIButton!
    private var doneButton: UIButton!
    private var bottomBar: UIView!
    private var colorStack: UIStackView!
    private var thicknessSlider: UISlider!
    private var undoButton: UIButton!
    private var isDrawing = false
    private var selectedColor: UIColor = .red
    private var selectedLineWidth: CGFloat = 3
    private var colorButtons: [UIButton] = []
    private var drawingOverlay: DrawingOverlayView!
    private var pdfDocument: PDFDocument?
    private var addedAnnotations: [(PDFPage, PDFAnnotation)] = []
    private var drawingGesture: UIPanGestureRecognizer!

    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupPDFView()
        setupOverlay()
        setupDrawingGesture()
        setupTopBar()
        setupBottomBar()
        if let url = pdfUrl {
            loadPDF(url: url)
        }
    }

    private func setupPDFView() {
        pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.topAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupOverlay() {
        drawingOverlay = DrawingOverlayView()
        drawingOverlay.isUserInteractionEnabled = false
        drawingOverlay.backgroundColor = .clear
        drawingOverlay.onDrawingFinished = { [weak self] path in
            self?.saveDrawing(path)
        }
        view.addSubview(drawingOverlay)
        drawingOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            drawingOverlay.topAnchor.constraint(equalTo: pdfView.topAnchor),
            drawingOverlay.leadingAnchor.constraint(equalTo: pdfView.leadingAnchor),
            drawingOverlay.trailingAnchor.constraint(equalTo: pdfView.trailingAnchor),
            drawingOverlay.bottomAnchor.constraint(equalTo: pdfView.bottomAnchor)
        ])
    }

    private func setupDrawingGesture() {
        drawingGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrawingPan(_:)))
        drawingGesture.maximumNumberOfTouches = 1
        drawingGesture.isEnabled = false
        drawingGesture.delegate = self
        pdfView.addGestureRecognizer(drawingGesture)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == drawingGesture {
            return true
        }
        return false
    }
    
    @objc private func handleDrawingPan(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: drawingOverlay)
        switch sender.state {
        case .began: drawingOverlay.startDrawing(at: location)
        case .changed: drawingOverlay.continueDrawing(to: location)
        case .ended, .cancelled: drawingOverlay.finishDrawing()
        default: break
        }
    }

    private func setupTopBar() {
        topBar = UIView()
        topBar.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 56)
        ])
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        drawButton = UIButton(type: .system)
        drawButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        drawButton.tintColor = .white
        drawButton.addTarget(self, action: #selector(drawTapped), for: .touchUpInside)
        let saveButton = UIButton(type: .system)
        saveButton.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        saveButton.tintColor = .white
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.systemGreen, for: .normal)
        doneButton.isHidden = true
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        let rightStack = UIStackView(arrangedSubviews: [drawButton, saveButton, doneButton])
        rightStack.axis = .horizontal
        rightStack.spacing = 16
        let mainStack = UIStackView(arrangedSubviews: [backButton, UIView(), rightStack])
        mainStack.axis = .horizontal
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -16),
            mainStack.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
        ])
    }

    private func setupBottomBar() {
        bottomBar = UIView()
        bottomBar.backgroundColor = UIColor(white: 0.1, alpha: 0.95)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.alpha = 0
        view.addSubview(bottomBar)
        colorStack = UIStackView()
        colorStack.axis = .horizontal
        colorStack.spacing = 12
        colorStack.translatesAutoresizingMaskIntoConstraints = false
        thicknessSlider = UISlider()
        thicknessSlider.minimumValue = 1
        thicknessSlider.maximumValue = 10
        thicknessSlider.value = Float(selectedLineWidth)
        thicknessSlider.addTarget(self, action: #selector(thicknessChanged), for: .valueChanged)
        undoButton = UIButton(type: .system)
        undoButton.setImage(UIImage(systemName: "arrow.uturn.backward"), for: .normal)
        undoButton.tintColor = .white
        undoButton.alpha = 0
        undoButton.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)
        [colorStack, thicknessSlider, undoButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            bottomBar.addSubview($0)
        }
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 120),
            colorStack.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 12),
            colorStack.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor),
            thicknessSlider.topAnchor.constraint(equalTo: colorStack.bottomAnchor, constant: 16),
            thicknessSlider.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 20),
            thicknessSlider.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -20),
            undoButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            undoButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 16)
        ])
        createColorButtons()
    }

    private func createColorButtons() {
        let colors: [UIColor] = [.red, .blue, .green, .yellow, .orange, .purple, .black]
        for (index, color) in colors.enumerated() {
            let btn = UIButton(type: .custom)
            btn.backgroundColor = color
            btn.layer.cornerRadius = 14
            btn.layer.borderWidth = 2
            btn.layer.borderColor = UIColor.clear.cgColor
            btn.tag = index
            btn.addTarget(self, action: #selector(colorTapped(_:)), for: .touchUpInside)
            NSLayoutConstraint.activate([
                btn.widthAnchor.constraint(equalToConstant: 28),
                btn.heightAnchor.constraint(equalToConstant: 28)
            ])
            colorButtons.append(btn)
            colorStack.addArrangedSubview(btn)
        }
        selectColor(index: 0)
    }

    private func selectColor(index: Int) {
        guard index < colorButtons.count else { return }
        colorButtons.forEach { $0.layer.borderColor = UIColor.clear.cgColor }
        let btn = colorButtons[index]
        btn.layer.borderColor = UIColor.white.cgColor
        selectedColor = btn.backgroundColor ?? .red
        drawingOverlay?.strokeColor = selectedColor
    }

    @objc private func closeTapped() {
        onClose?()
    }
    
    @objc private func drawTapped() {
        isDrawing = true
        drawingGesture.isEnabled = true
        drawingOverlay.lineWidth = selectedLineWidth
        drawingOverlay.strokeColor = selectedColor
        drawButton.isHidden = true
        doneButton.isHidden = false
        UIView.animate(withDuration: 0.25) { self.bottomBar.alpha = 1 }
    }

    @objc private func doneTapped() {
        isDrawing = false
        drawingGesture.isEnabled = false
        doneButton.isHidden = true
        drawButton.isHidden = false
        UIView.animate(withDuration: 0.25) { self.bottomBar.alpha = 0 }
    }

   @objc private func saveTapped() {
    // 1. Get the PDF Data
    guard let data = pdfDocument?.dataRepresentation() else { return }
    
    // 2. Save to a temporary file URL
    let fileName = "Annotated_Document.pdf" // You can name this whatever you want
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    
    do {
        try data.write(to: url)
        
        // 3. Present the standard iOS Share Sheet
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        // Required for iPad to prevent crashing
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topBar // Show arrow from the top bar
            popover.sourceRect = CGRect(x: topBar.bounds.maxX - 60, y: topBar.bounds.midY, width: 0, height: 0)
        }
        
        present(activityVC, animated: true)
        
        // 4. Notify the callback (optional)
        onPdfSaved?(url.path)
        
    } catch {
        print("Error saving PDF: \(error)")
    }
}

    @objc private func colorTapped(_ sender: UIButton) { selectColor(index: sender.tag) }

    @objc private func thicknessChanged(_ slider: UISlider) {
        selectedLineWidth = CGFloat(slider.value)
        drawingOverlay.lineWidth = selectedLineWidth
    }

    @objc private func undoTapped() {
        guard let last = addedAnnotations.popLast() else { return }
        last.0.removeAnnotation(last.1)
        pdfView.setNeedsDisplay()
        if addedAnnotations.isEmpty { undoButton.alpha = 0 }
    }

    private func saveDrawing(_ path: UIBezierPath) {
        guard let page = pdfView.currentPage else { return }
        let pdfPath = UIBezierPath()
        pdfPath.lineWidth = selectedLineWidth
        pdfPath.lineCapStyle = .round
        path.cgPath.applyWithBlock { element in
            let point = element.pointee.points[0]
            let converted = self.pdfView.convert(point, to: page)
            if element.pointee.type == .moveToPoint { pdfPath.move(to: converted) }
            else if element.pointee.type == .addLineToPoint { pdfPath.addLine(to: converted) }
        }
        let annotation = PDFAnnotation(bounds: page.bounds(for: .mediaBox), forType: .ink, withProperties: nil)
        annotation.color = selectedColor
        let border = PDFBorder()
        border.lineWidth = selectedLineWidth
        annotation.border = border
        annotation.add(pdfPath)
        page.addAnnotation(annotation)
        addedAnnotations.append((page, annotation))
        undoButton.alpha = 1
    }

    private func loadPDF(url: URL) {
        pdfDocument = PDFDocument(url: url)
        pdfView.document = pdfDocument
    }
}
