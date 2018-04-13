import UIKit

class RegularPolygonPath: UIBezierPath {
    private let sides: Int
    private let center: CGPoint
    private let radius: CGFloat
    private let offset: CGFloat
    
    // MARK: - Init & Setup
    init(sides: Int, center: CGPoint, radius: CGFloat, offset: CGFloat) {
        self.sides = sides
        self.center = center
        self.radius = radius
        self.offset = offset
        
        super.init()
        self.setupPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()    // should not be used
    }
    
    private func setupPath() {
        let anglePerSide = (360 / CGFloat(self.sides)).radians
        
        let offsetRadians = self.offset.radians
        
        // add a path for each side
        for i in 0...sides {
            let x = self.center.x + self.radius * cos(anglePerSide * CGFloat(i) - offsetRadians)
            let y = self.center.y + self.radius * sin(anglePerSide * CGFloat(i) - offsetRadians)
            
            let point = CGPoint(x: x, y: y)
            
            // if this is the first point, just move, otherwise draw the line
            if i == 0 {
                self.move(to: point)
            } else {
                self.addLine(to: point)
            }
        }
        
        self.close()
    }
}
