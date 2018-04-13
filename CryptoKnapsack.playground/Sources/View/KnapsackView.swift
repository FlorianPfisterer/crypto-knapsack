import UIKit

/// Contains the selected Knapsack items
class KnapsackView: UIView {
    var capacity: UInt = 1 {
        didSet {
            self.updateLevel(animated: true)
        }
    }
    
    var currentLevel: UInt = 0 {
        didSet {
            self.updateLevel(animated: true)
        }
    }
    
    var currentProfit: UInt = 0 {
        didSet {
            self.profitLabel.text = self.currentProfit.currencyString
        }
    }
    
    var unit: String = "GB" {
        didSet {
            self.updateLevel(animated: false)
        }
    }
    
    private var itemViews: [ItemView] = []
    private var addNextItemLeft: Bool = true
    
    // MARK: - Subviews
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .darkText
        label.font = levelLabelFont
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = .headline
        label.textColor = .darkText
        label.text = "KNAPSACK"
        return label
    }()
    
    private let profitLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = profitFont
        label.textColor = .darkText
        label.text = "$0"
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInitialization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInitialization()
    }
    
    private func sharedInitialization() {
        self.addSubview(self.levelLabel)
        self.addSubview(self.profitLabel)
        self.addSubview(self.titleLabel)
        
        self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor).activate()
        self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).activate()
        self.titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: self.offset - (levelLabelWidth + levelLabelSpacing)).activate()
        
        self.profitLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).activate()
        self.profitLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).activate()
        self.profitLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: self.offset - (levelLabelWidth + levelLabelSpacing)).activate()
        
        self.updateLevel(animated: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.levelLabel.frame.size.width = levelLabelWidth
        self.updateLevel(animated: false)
        
        self.setNeedsDisplay()
    }
    
    // MARK: - Public Interface
    func add(item: Item, withView view: ItemView) {
        precondition(item.size + self.currentLevel <= self.capacity)
        self.currentLevel += item.size
        self.currentProfit += item.profit
        self.itemViews.append(view)
    }
    
    func remove(item: Item, withView view: ItemView) {
        precondition(self.currentLevel - item.size >= 0)
        self.currentLevel -= item.size
        self.currentProfit -= item.profit
        
        if let index = self.itemViews.index(of: view) {
            self.itemViews.remove(at: index)
        }
    }
    
    func getFrameForNextItem(_ item: Item, atLevel customLevel: UInt? = nil) -> CGRect {
        var height = (CGFloat(item.size) / CGFloat(self.capacity)) * self.contentHeight
        var width = self.contentWidth * 0.7
        
        let area = height * width
        height = min(sqrt(area), width)
        width = height
        
        let x = self.addNextItemLeft ? lineWidth : (self.contentWidth - width)
        self.addNextItemLeft = !self.addNextItemLeft
        let y = self.contentHeight - (CGFloat(customLevel ?? self.currentLevel) / CGFloat(self.capacity)) * self.contentHeight - height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

extension KnapsackView {
    var contentFrame: CGRect {
        return CGRect(x: self.offset,
                      y: self.offset + topMargin,
                      width: self.contentWidth,
                      height: self.contentHeight)
    }
    
    private var currentLevelY: CGFloat {
        let proportion = CGFloat(self.currentLevel) / CGFloat(self.capacity)
        let contentFrame = self.contentFrame
        let baseY = contentFrame.origin.y
        
        return baseY + (1-proportion) * contentFrame.height
    }
    
    private func updateLevel(animated: Bool) {
        let newText = "\(self.currentLevel) \(self.unit)"
        
        let maxY = self.currentLevelY - 9
        let newOrigin = CGPoint(x: self.contentFrame.maxX + levelLabelSpacing, y: maxY)
        
        let animations = {
            self.levelLabel.text = newText
            self.levelLabel.frame.origin = newOrigin
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: animations, completion: nil)
        } else {
            animations()
        }
    }
}

private let levelLabelFont = UIFont(name: "Menlo", size: 15) ?? .systemFont(ofSize: 15, weight: .light)
private let levelLabelWidth: CGFloat = "512 GB".size(withFont: levelLabelFont).width
private let levelLabelSpacing: CGFloat = 10
private let topMargin: CGFloat = 20
private let lineWidth: CGFloat = 6

private let profitFont = UIFont.systemFont(ofSize: 16, weight: .heavy)
private let profitLabelHeight = "$0".size(withFont: profitFont).height
private let profitLabelMargin: CGFloat = 5
extension KnapsackView {
    private var contentWidth: CGFloat {
        return self.bounds.size.width - lineWidth - levelLabelWidth - levelLabelSpacing
    }
    
    private var contentHeight: CGFloat {
        return self.bounds.size.height - lineWidth - topMargin - profitLabelHeight - profitLabelMargin
    }
    
    var lineOffset: CGFloat {
        return lineWidth/2
    }
    
    var rightOffset: CGFloat {
        return levelLabelWidth + levelLabelSpacing + lineWidth
    }
    
    private var offset: CGFloat {
        return lineWidth / 2
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        let contentFrame = self.contentFrame
        path.move(to: CGPoint(x: contentFrame.minX, y: contentFrame.minY))
        path.addLine(to: CGPoint(x: contentFrame.minX, y: contentFrame.maxY))
        path.addLine(to: CGPoint(x: contentFrame.maxX, y: contentFrame.maxY))
        path.addLine(to: CGPoint(x: contentFrame.maxX, y: contentFrame.minY))
        UIColor.black.setStroke()
        path.stroke()
    }
}

