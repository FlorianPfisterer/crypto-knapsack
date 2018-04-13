import UIKit

protocol ItemViewDelegate: class {
    func hitItem(withId id: Int)
}

/// The visualization of a Knapsack item. Displays the size and profit of the item it represents.
class ItemView: UIControl {
    private let id: Int
    let item: Item
    
    weak var delegate: ItemViewDelegate?
    
    // MARK: - Subviews
    private let profitLabel: CurvedLabel = {
        let label = CurvedLabel()
        label.clockwise = true
        label.text = "$0"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.bold)
        label.textColor = .black
        return label
    }()
    
    private let sizeLabel: CurvedLabel = {
        let label = CurvedLabel()
        label.angle = 1.5 * π
        label.clockwise = false
        label.text = "0 GB"
        label.textAlignment = .center
        label.font = UIFont(name: "Menlo", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.bold)
        label.textColor = .black
        return label
    }()
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "AAA"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.heavy)
        label.textColor = .black
        return label
    }()
    
    private let innerRingMaskLayer = CAShapeLayer()
    private let ringMaskLayer = CAShapeLayer()
    private let maskLayer = CAShapeLayer()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "gold.png")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let ringImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "silver.png")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let foregroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "gold.png")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Init
    init(id: Int, item: Item) {
        self.id = id
        self.item = item
        super.init(frame: .zero)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setup() {
        self.addSubview(self.backgroundImageView)
        
        self.addSubview(self.ringImageView)
        self.ringImageView.layer.mask = self.ringMaskLayer
        
        self.addSubview(self.foregroundImageView)
        self.foregroundImageView.layer.mask = self.innerRingMaskLayer
        
        self.layer.masksToBounds = true
        self.layer.mask = self.maskLayer
        
        self.profitLabel.text = self.item.profit.currencyString
        self.sizeLabel.text = "\(self.item.size) GB"
        self.symbolLabel.text = "\(self.item.description)"
        
        self.addSubview(self.profitLabel)
        self.addSubview(self.sizeLabel)
        self.addSubview(self.symbolLabel)
        
        self.addTarget(self, action: #selector(self.hit), for: .touchUpInside)
    }
    
    @objc func hit() {
        self.delegate?.hitItem(withId: self.id)
    }
}

// MARK: - Round Collision Behavior
private let sides: Int = 15
private let ringWidth: CGFloat = 17
private let outerRingWidth: CGFloat = 3
private let labelInset: CGFloat = 2
extension ItemView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.profitLabel.frame = self.bounds.insetBy(dx: labelInset, dy: labelInset)
        self.sizeLabel.frame = self.bounds.insetBy(dx: labelInset, dy: labelInset)
        self.symbolLabel.frame = self.bounds.insetBy(dx: labelInset, dy: labelInset)
        
        self.backgroundImageView.frame = self.bounds
        self.ringImageView.frame = self.bounds
        self.foregroundImageView.frame = self.bounds
        
        // add the regular polygon paths
        let radius = min(self.bounds.width, self.bounds.height) / 2
        let center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        
        self.innerRingMaskLayer.path = self.getPath(center: center, radius: radius - ringWidth - outerRingWidth).cgPath
        self.ringMaskLayer.path = self.getPath(center: center, radius: radius - outerRingWidth).cgPath
        self.maskLayer.path = self.getPath(center: center, radius: radius).cgPath
    }
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .path
    }
    
    private func getPath(center: CGPoint, radius: CGFloat) -> UIBezierPath {
        return RegularPolygonPath(sides: sides, center: center, radius: radius, offset: 0)
    }
    
    override var collisionBoundingPath: UIBezierPath {
        return self.getPath(center: .zero, radius: min(self.bounds.width, self.bounds.height) / 2)
    }
}


