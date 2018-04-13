import Foundation
import UIKit

// MARK: - Foundation Extensions
extension String {
    func size(withFont font: UIFont) -> CGSize {
        return (self as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0.0), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : font], context: nil).size
    }
}

/// Formats integer numbers to $-currency strings
private let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.minimumFractionDigits = 0
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()
extension UInt {
    var currencyString: String {
        return currencyFormatter.string(from: self as NSNumber) ?? "$\(self)"
    }
}

// MARK: - UIKit Extensions
extension UIView {
    func constrainToEdges(of view: UIView, spacing: CGFloat) {
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: spacing).activate()
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: spacing).activate()
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing).activate()
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: spacing).activate()
    }
    
    func constrainToCenter(of view: UIView) {
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor).activate()
    }
}

extension UIView {
    /// Performs a 3x0.05 sec shake animation and then executes the then closure given
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 7, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 7, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
}

extension NSLayoutConstraint {
    func activate() {
        self.isActive = true
    }
}

extension CGFloat {
    var radians: CGFloat {
        return π * self / 180
    }
}

extension UIColor {
    static var random: UIColor {
        let hue = CGFloat(arc4random() % 256) / 256.0
        let saturation = CGFloat(arc4random() % 128) / 256.0 + 0.5
        let brightness = CGFloat(arc4random() % 128) / 256.0 + 0.5
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
}

extension UIBezierPath {
    func from(_ point: CGPoint) -> UIBezierPath {
        self.move(to: point)
        return self
    }
    
    func to(_ point: CGPoint) -> UIBezierPath {
        self.addLine(to: point)
        return self
    }
    
    func stroke(color: UIColor) {
        color.setStroke()
        self.stroke()
    }
}

extension CGVector {
    var length: CGFloat {
        return sqrt(self.dx * self.dx + self.dy * self.dy)
    }
}

