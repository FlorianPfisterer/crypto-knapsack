import UIKit
import UIKit.UIGestureRecognizerSubclass

/// Helper Class that translates pan gestures to 2D-rotation gestures
class AngleGestureRecognizer: UIPanGestureRecognizer {
    private var startAngle: CGFloat? = nil
    private var currentTouchAngle: CGFloat = 0
    private var currentDistanceToCenter: CGFloat = 0

    // MARK: - Init
    init() {
        super.init(target: nil, action: nil)
        self.minimumNumberOfTouches = 1
        self.maximumNumberOfTouches = 1
    }
}

// MARK: - Helper Functions to Calculate the Angle etc.
extension AngleGestureRecognizer {
    var angleDelta: CGFloat {
        guard let startAngle = self.startAngle else {
            return 0
        }
        return self.currentTouchAngle - startAngle
    }
    
    private func calculateAngle(toPoint point: CGPoint) -> CGFloat {
        guard let bounds = self.view?.bounds else {
            return 0
        }
        
        let centerOffset = CGVector(dx: point.x - bounds.midX, dy: point.y - bounds.midY)
        self.currentDistanceToCenter = centerOffset.length
        return atan2(centerOffset.dy, centerOffset.dx)
    }
    
    private func updateTouchAngle(withTouches touches: Set<UITouch>) {
        if let touchPoint = touches.first?.location(in: self.view) {
            self.currentTouchAngle = self.calculateAngle(toPoint: touchPoint)
        }
    }
}

// MARK: - Touches Functions Overrides
extension AngleGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.updateTouchAngle(withTouches: touches)
        self.startAngle = self.currentTouchAngle
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        self.updateTouchAngle(withTouches: touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        self.currentTouchAngle = 0
        self.startAngle = nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        self.currentTouchAngle = 0
        self.startAngle = nil
    }
}
