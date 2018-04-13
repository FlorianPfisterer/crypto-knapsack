import UIKit

/// Contains the whole UI Setup of the Knapsack Visualization. Manages the layout and algorithms.
public class KnapsackContainerView: UIView {
    private let controlsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "CryptoKnapsack"
        return label
    }()
    
    private let coinsTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .headline
        label.text = "COINS"
        return label
    }()
    
    private let capacityTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .headline
        label.text = "CAPACITY"
        return label
    }()
    
    private let capacitySlider: CircularSliderControl = {
        let control = CircularSliderControl()
        control.backgroundColor = .clear
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let algorithmTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .headline
        label.text = "ALGORITHM"
        return label
    }()
    
    private let algorithmChooser: HorizontalScrollSegmentedControl = {
        let control = HorizontalScrollSegmentedControl()
        control.backgroundColor = .clear
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private lazy var knapsackView: KnapsackView = {
        let view = KnapsackView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let buttonControlsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 5
        return stackView
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.tintColor = .darkGray
        button.setImage(#imageLiteral(resourceName: "play.png").withRenderingMode(.alwaysTemplate), for: .normal)
        return button
    }()
    
    private let stopButton: UIButton = {
        let button = UIButton()
        button.tintColor = .darkGray
        button.isEnabled = false
        button.setImage(#imageLiteral(resourceName: "stop.png").withRenderingMode(.alwaysTemplate), for: .normal)
        return button
    }()
    
    private lazy var dynamicAnimator: UIDynamicAnimator = {
        return UIDynamicAnimator(referenceView: self)
    }()
    private let gravityBehavior = UIGravityBehavior()
    private let collisionBehavior = UICollisionBehavior()
    private let dynamicItemBehavior = UIDynamicItemBehavior()
    
    private let itemInfos: [ItemInfo] = ItemInfo.all
    private var capacity: UInt = 1 {
        didSet {
            self.knapsackView.capacity = self.capacity
        }
    }
    
    private var itemViews: [ItemView] = []
    private var selectedItemIds: [Int] = []
    private var algorithms: [KnapsackAlgorithm] = []  // TODO DEBUG
    
    private var isRunningAlgorithm: Bool = false {
        didSet {
            self.playButton.isEnabled = !self.isRunningAlgorithm
            self.stopButton.isEnabled = self.isRunningAlgorithm
        }
    }
    private var ignoreAlgorithm: Bool = false
    private lazy var solver: KnapsackSolver = {
        return KnapsackSolver(instance: self, withDelay: 0.7, initialDelay: 0.3)
    }()
    
    // MARK: - Init & Setup
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInitialization()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInitialization()
    }
    
    private func sharedInitialization() {
        self.backgroundColor = .white
        
        self.addSubview(self.titleLabel)
        self.addSubview(self.coinsTitleLabel)
        self.addSubview(self.knapsackView)
        self.addSubview(self.controlsContainer)
        
        self.controlsContainer.addSubview(self.capacityTitleLabel)
        self.controlsContainer.addSubview(self.capacitySlider)
        self.controlsContainer.addSubview(self.algorithmTitleLabel)
        self.controlsContainer.addSubview(self.algorithmChooser)
        self.controlsContainer.addSubview(self.buttonControlsStackView)
        
        self.setupConstraints()
        self.setupItemViews()
        
        self.setupDynamicBehaviors()
        self.setupControls()
    }
    
    private func setupDynamicBehaviors() {
        self.gravityBehavior.magnitude = 1.25
        self.dynamicAnimator.addBehavior(self.gravityBehavior)
        self.dynamicAnimator.addBehavior(self.collisionBehavior)
    }
    
    private let lowerCollisionIdentifier: NSCopying = "lowerCollision" as NSString
    private let leftCollisionIdentifier: NSCopying = "leftCollision" as NSString
    private let rightCollisionIdentifier: NSCopying = "rightCollision" as NSString
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.collisionBehavior.removeAllBoundaries()
        
        // add collision boundaries that reflect the edges of the knapsack container view
        let sackFrame = self.knapsackView.contentFrame.offsetBy(dx: self.knapsackView.frame.origin.x, dy: self.knapsackView.frame.origin.y)
            .insetBy(dx: self.knapsackView.lineOffset-1, dy: self.knapsackView.lineOffset-2)
        
        self.collisionBehavior.addBoundary(withIdentifier: self.lowerCollisionIdentifier,
                                           from: CGPoint(x: sackFrame.minX, y: sackFrame.maxY),
                                           to: CGPoint(x: sackFrame.maxX, y: sackFrame.maxY))
        self.collisionBehavior.addBoundary(withIdentifier: self.leftCollisionIdentifier,
                                           from: CGPoint(x: sackFrame.minX, y: 0),
                                           to: CGPoint(x: sackFrame.minX, y: sackFrame.maxY))
        self.collisionBehavior.addBoundary(withIdentifier: self.rightCollisionIdentifier,
                                           from: CGPoint(x: sackFrame.maxX, y: 0),
                                           to: CGPoint(x: sackFrame.maxX, y: sackFrame.maxY))
    }
}

// MARK: - Item Views
private let headerHeight: CGFloat = 30
private let headerMargin: CGFloat = 20
extension KnapsackContainerView: ItemViewDelegate {
    private func setupItemViews() {
        self.itemViews.forEach { $0.removeFromSuperview() }
        self.itemViews = self.itemInfos.map { info in
            
            let itemView = ItemView(id: info.item.id, item: info.item)
            itemView.delegate = self
            itemView.frame = info.frame.offsetBy(dx: 0, dy: headerHeight + headerMargin)
            self.addSubview(itemView)
            
            return itemView
        }
        
        self.knapsackView.capacity = self.capacity
    }
    
    /// Sums up the sizes of all items currently selected
    private var currentSize: UInt {
        return self.selectedItemIds.map { self.itemInfos[$0].item.size }.reduce(0, +)
    }
    
    func hitItem(withId id: Int) {
        if !self.isRunningAlgorithm {
            self.switchStateOfItem(withId: id)
        }
    }
    
    private func switchStateOfItem(withId id: Int) {
        let info = self.itemInfos[id]
        let itemView = self.itemViews[id]
        
        if let index = self.selectedItemIds.index(of: id) {
            self.selectedItemIds.remove(at: index)
            self.selectItem(false, itemInfo: info, withView: itemView)
        } else {
            if info.item.size + self.currentSize > self.capacity {
                itemView.shake()
            } else {
                self.selectedItemIds.append(id)
                self.selectItem(true, itemInfo: info, withView: itemView)
            }
        }
    }
    
    private func selectItem(_ select: Bool, itemInfo: ItemInfo, withView view: ItemView) {
        let frame: CGRect = select ?
            self.knapsackView.getFrameForNextItem(itemInfo.item).offsetBy(dx: self.knapsackView.frame.origin.x, dy: self.knapsackView.frame.origin.y)
            : itemInfo.frame.offsetBy(dx: 0, dy: headerHeight + headerMargin)
        
        if !select {
            self.addDynamicBehaviors(false, toView: view)
        }
        
        view.transform = .identity
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            view.frame = frame
        }, completion: { _ in
            if select {
                self.addDynamicBehaviors(true, toView: view)
            }
        })
        
        if select {
            self.knapsackView.add(item: itemInfo.item, withView: view)
        } else {
            self.knapsackView.remove(item: itemInfo.item, withView: view)
        }
    }
    
    
    /// Adds or removes the dynamic animator behaviors from / to the given view
    ///
    /// - Parameters:
    ///   - add: whether to add or remove the behaviors
    ///   - view: the item view from which to remove / to which to add the behaviors
    private func addDynamicBehaviors(_ add: Bool, toView view: ItemView) {
        if add {
            self.gravityBehavior.addItem(view)
            self.collisionBehavior.addItem(view)
            self.dynamicItemBehavior.addItem(view)
        } else {
            self.gravityBehavior.removeItem(view)
            self.collisionBehavior.removeItem(view)
            self.dynamicItemBehavior.removeItem(view)
        }
    }
}

// MARK: - Algorithm Chooser
extension KnapsackContainerView: HorizontalScrollSegmentedControlDataSource {
    func numberOfItems() -> Int {
        return self.algorithms.count
    }
    
    func title(forItemAtIndex index: Int) -> String {
        return self.algorithms[index].displayName
    }
    
    @objc func playButtonPressed() {
        self.ignoreAlgorithm = false
        if self.isRunningAlgorithm {
            return
        } else {
            self.isRunningAlgorithm = true
        }
        
        let selectedIndex = self.algorithmChooser.selectedIndex
        guard self.algorithms.count > selectedIndex else {
            return
        }
        let algorithm = self.algorithms[selectedIndex]
        self.solver.startAlgorithm(algorithm)
    }
    
    @objc func stopButtonPressed() {
        self.isRunningAlgorithm = false
        self.ignoreAlgorithm = true
    }
}

// MARK: - KnapsackInstance Protocol Implementation
extension KnapsackContainerView: KnapsackInstance {
    public var items: [Item] {
        return self.itemInfos.map { $0.item }
    }
    
    public var maxSize: UInt {
        return self.capacity
    }
    
    public func reset() {
        for id in self.selectedItemIds {
            self.selectItem(false, itemInfo: self.itemInfos[id], withView: self.itemViews[id])
        }
        self.selectedItemIds = []
    }
    
    public func addItem(withId id: Int) {
        if !self.ignoreAlgorithm {
            self.switchStateOfItem(withId: id)
        }
    }
    
    public func finished() {
        self.isRunningAlgorithm = false
        self.ignoreAlgorithm = false
        
        // TODO show score etc.
    }
    
    public func addAlgorithm(_ algorithm: KnapsackAlgorithm) {
        self.algorithms.append(algorithm)
        self.algorithmChooser.reloadData()
    }
}

// MARK: - Constraints & Layout
private let containerHeightFraction: CGFloat = 0.5
private let containerWidthFraction: CGFloat = 0.55
private let controlsSpacing: CGFloat = 30
extension KnapsackContainerView {
    private func setupConstraints() {
        self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor).activate()
        self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).activate()
        self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).activate()
        self.titleLabel.heightAnchor.constraint(equalToConstant: headerHeight).activate()
        
        self.coinsTitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 10).activate()
        self.coinsTitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).activate()
        
        self.knapsackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).activate()
        self.knapsackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).activate()
        self.knapsackView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: containerHeightFraction).activate()
        self.knapsackView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: containerWidthFraction).activate()
        
        self.controlsContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor).activate()
        self.controlsContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor).activate()
        self.controlsContainer.heightAnchor.constraint(equalTo: self.knapsackView.heightAnchor).activate()
        self.controlsContainer.leadingAnchor.constraint(equalTo: self.knapsackView.trailingAnchor, constant: internalContainerSpacing).activate()
        
        self.capacityTitleLabel.topAnchor.constraint(equalTo: self.controlsContainer.topAnchor).activate()
        self.capacityTitleLabel.leadingAnchor.constraint(equalTo: self.controlsContainer.leadingAnchor).activate()
        self.capacityTitleLabel.trailingAnchor.constraint(equalTo: self.controlsContainer.trailingAnchor).activate()
        
        self.capacitySlider.widthAnchor.constraint(equalTo: self.capacitySlider.heightAnchor).activate()
        self.capacitySlider.topAnchor.constraint(equalTo: self.capacityTitleLabel.bottomAnchor).activate()
        self.capacitySlider.leadingAnchor.constraint(equalTo: self.controlsContainer.leadingAnchor).activate()
        self.capacitySlider.trailingAnchor.constraint(equalTo: self.controlsContainer.trailingAnchor).activate()
        
        self.algorithmTitleLabel.topAnchor.constraint(equalTo: self.capacitySlider.bottomAnchor, constant: controlsSpacing).activate()
        self.algorithmTitleLabel.leadingAnchor.constraint(equalTo: self.controlsContainer.leadingAnchor).activate()
        self.algorithmTitleLabel.trailingAnchor.constraint(equalTo: self.controlsContainer.trailingAnchor).activate()
        
        self.algorithmChooser.topAnchor.constraint(equalTo: self.algorithmTitleLabel.bottomAnchor).activate()
        self.algorithmChooser.leadingAnchor.constraint(equalTo: self.controlsContainer.leadingAnchor).activate()
        self.algorithmChooser.trailingAnchor.constraint(equalTo: self.controlsContainer.trailingAnchor).activate()
        self.algorithmChooser.heightAnchor.constraint(equalToConstant: HorizontalScrollSegmentedControl.frameHeight).activate()
        
        self.buttonControlsStackView.topAnchor.constraint(equalTo: self.algorithmChooser.bottomAnchor).activate()
        self.buttonControlsStackView.centerXAnchor.constraint(equalTo: self.controlsContainer.centerXAnchor).activate()
    }
    
    private func setupControls() {
        self.capacitySlider.addTarget(self, action: #selector(self.capacityValueChanged), for: .valueChanged)
        self.capacityValueChanged() // initial setup
        
        self.algorithmChooser.dataSource = self
        self.algorithmChooser.addTarget(self, action: #selector(self.algorithmValueChanged), for: .valueChanged)
        self.algorithmChooser.reloadData()
        
        self.stopButton.addTarget(self, action: #selector(self.stopButtonPressed), for: .touchUpInside)
        self.buttonControlsStackView.addArrangedSubview(self.stopButton)
        
        self.playButton.addTarget(self, action: #selector(self.playButtonPressed), for: .touchUpInside)
        self.buttonControlsStackView.addArrangedSubview(self.playButton)
    }
    
    @objc func algorithmValueChanged() {
        self.stopButtonPressed()
    }
    
    @objc func capacityValueChanged() {
        self.capacity = self.capacitySlider.value
        
        // update the selected views
        let selectedIdsCopy = self.selectedItemIds
        var simulatedLevel: UInt = 0
        
        for id in selectedIdsCopy {
            let info = self.itemInfos[id]
            let item = info.item
            let itemView = self.itemViews[id]
            
            self.addDynamicBehaviors(false, toView: itemView)
            
            if item.size + simulatedLevel > self.capacity {
                // deselect
                if let index = self.selectedItemIds.index(of: id) {
                    self.selectedItemIds.remove(at: index)
                }
                
                self.selectItem(false, itemInfo: info, withView: itemView)
            } else {
                // set new frame
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                    itemView.transform = .identity
                    itemView.frame = self.knapsackView
                        .getFrameForNextItem(item, atLevel: simulatedLevel)
                        .offsetBy(dx: self.knapsackView.frame.origin.x, dy: self.knapsackView.frame.origin.y)
                }, completion: { _ in
                    self.addDynamicBehaviors(true, toView: itemView)
                })
                
                simulatedLevel += item.size
            }
        }
    }
}


