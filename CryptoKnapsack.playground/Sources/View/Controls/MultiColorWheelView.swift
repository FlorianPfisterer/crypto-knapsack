import UIKit

protocol ColorDelegate: class {
    func colorForWheel(atProportion proportion: CGFloat) -> UIColor
}

/// Circular Wheel that asks its delegate for the color at each angle.
class MultiColorWheelView: UIView {
    var arcWidth: CGFloat = 20 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    weak var colorDelegate: ColorDelegate?
    
    static let colorSegmentCount: UInt = 512
}

extension MultiColorWheelView {
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.saveGState()
        
        let bounds = self.bounds
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let arcRadius: CGFloat = (min(bounds.width, bounds.height) - self.arcWidth) / 2
        
        context.setLineCap(.butt)
        context.setLineWidth(self.arcWidth)
        
        // for each segment, draw a proportion of the arc in the corresponding color
        for segment in 0..<MultiColorWheelView.colorSegmentCount {
            let proportion = CGFloat(segment) / CGFloat(MultiColorWheelView.colorSegmentCount)
            let nextProportion = CGFloat(segment + 1) / CGFloat(MultiColorWheelView.colorSegmentCount)

            let startAngle = 2*π * proportion - (π/2)
            let endAngle = 2*π * nextProportion - (π/2)

            context.addArc(center: center, radius: arcRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)

            let color = self.colorDelegate?.colorForWheel(atProportion: proportion) ?? .black
            context.setStrokeColor(color.cgColor)
            context.strokePath()
        }
        
        context.restoreGState()
    }
}
