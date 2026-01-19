import UIKit

public class DrawingOverlayView: UIView {

    public var strokeColor: UIColor = .red
    public var lineWidth: CGFloat = 3
    public var onDrawingFinished: ((UIBezierPath) -> Void)?

    private var path: UIBezierPath?

    public func startDrawing(at point: CGPoint) {
        path = UIBezierPath()
        path?.lineWidth = lineWidth
        path?.lineCapStyle = .round
        path?.lineJoinStyle = .round
        path?.move(to: point)
        setNeedsDisplay()
    }

    public func continueDrawing(to point: CGPoint) {
        path?.addLine(to: point)
        setNeedsDisplay()
    }

    public func finishDrawing() {
        guard let path = path else { return }
        onDrawingFinished?(path)
        self.path = nil
        setNeedsDisplay()
    }

    public override func draw(_ rect: CGRect) {
        strokeColor.setStroke()
        path?.stroke()
    }
}
