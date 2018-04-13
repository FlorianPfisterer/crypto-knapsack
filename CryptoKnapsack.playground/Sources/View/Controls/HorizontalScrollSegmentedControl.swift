import UIKit

protocol HorizontalScrollSegmentedControlDataSource: class {
    func title(forItemAtIndex index: Int) -> String
    func numberOfItems() -> Int
}

/// Control that consists of a horizontal scroll area with items (String titles) to be selected
class HorizontalScrollSegmentedControl: UIControl {
    // MARK: - Public Properties
    weak var dataSource: HorizontalScrollSegmentedControlDataSource? = nil
    static let frameHeight: CGFloat = 35
    
    // MARK: - Private Properties & Subviews
    private var titleLabels: [UILabel] = []
    private(set) var selectedIndex: Int = 0 {
        didSet {
            if self.selectedIndex != oldValue {
                self.didSelectIndex()
            }
        }
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.scrollsToTop = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = false
        scrollView.isScrollEnabled = true
        scrollView.contentInset = .zero
        return scrollView
    }()
    
    private let selectedContentView = UIView()
    private let selectedIndicatorView = UIView()
    private let selectedLabelMaskView = UIView()
    
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
        self.addSubview(UIView())
        self.addSubview(self.scrollView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame = self.bounds
        self.selectedContentView.frame = self.bounds
    }
}

// MARK: - ScrollView Setup
private let titleColor: UIColor = .lightGray
private let selectedTitleColor: UIColor = .white
private let titleFont: UIFont = .systemFont(ofSize: 13)
private let indicatorColor: UIColor = .black //UIColor(white: 0.95, alpha: 1)
private let titleHorizontalMargin: CGFloat = 3
private let verticalSpacing: CGFloat = 10
private let horizontalSpacing: CGFloat = 8
extension HorizontalScrollSegmentedControl {
    private func clear() {
        self.titleLabels = []
        self.scrollView.subviews.forEach { $0.removeFromSuperview() }
        self.selectedContentView.subviews.forEach { $0.removeFromSuperview() }
        
        for recognizer in self.gestureRecognizers ?? [] {
            self.removeGestureRecognizer(recognizer)
        }
    }
    
    func reloadData() {
        self.clear()
        
        guard let dataSource = self.dataSource else {
            return
        }
        
        // create title labels
        let numberOfItems = dataSource.numberOfItems()
        guard numberOfItems > 0 else {
            return
        }
        
        let lineHeight = titleFont.lineHeight
        var labelX: CGFloat = 0
        let labelY: CGFloat = (HorizontalScrollSegmentedControl.frameHeight - lineHeight) / 2
        
        self.selectedLabelMaskView.backgroundColor = UIColor.black
        self.selectedContentView.layer.mask = self.selectedLabelMaskView.layer

        self.selectedLabelMaskView.isUserInteractionEnabled = true
        
        for i in 0..<numberOfItems {
            let title = dataSource.title(forItemAtIndex: i)
            
            let titleWidth = title.size(withFont: titleFont).width + horizontalSpacing * 2
            labelX = (self.titleLabels.last?.frame.maxX ?? 0) + titleHorizontalMargin
            
            let frame = CGRect(x: labelX, y: labelY, width: titleWidth, height: lineHeight)
            
            let backgroundLabel = UILabel(frame: frame)
            backgroundLabel.text = title
            backgroundLabel.textColor = titleColor
            backgroundLabel.font = titleFont
            backgroundLabel.textAlignment = .center
            backgroundLabel.tag = i
            
            self.titleLabels.append(backgroundLabel)
            self.scrollView.addSubview(backgroundLabel)
            
            let foregroundLabel = UILabel(frame: frame)
            foregroundLabel.text = title
            foregroundLabel.textColor = selectedTitleColor
            foregroundLabel.font = titleFont
            foregroundLabel.textAlignment = .center
            foregroundLabel.tag = i
            
            self.selectedContentView.addSubview(foregroundLabel)
            
            if i == numberOfItems - 1 {
                let contentWidth = frame.maxX + titleHorizontalMargin
                self.scrollView.contentSize.width = contentWidth
                self.selectedContentView.frame.size.width = contentWidth
            }
        }
        
        // add cover cview
        self.selectedIndicatorView.backgroundColor = indicatorColor
        self.scrollView.addSubview(self.selectedIndicatorView)
        self.scrollView.addSubview(self.selectedContentView)
        
        let coverHeight = lineHeight + verticalSpacing
        let coverWidth = self.titleLabels[0].frame.size.width
        let coverX = self.titleLabels[0].frame.origin.x
        let coverY = (HorizontalScrollSegmentedControl.frameHeight - coverHeight) / 2
        
        let indicatorFrame = CGRect(x: coverX, y: coverY, width: coverWidth, height: coverHeight)
        self.selectedIndicatorView.frame = indicatorFrame
        self.selectedLabelMaskView.frame = indicatorFrame
        
        self.selectedIndicatorView.layer.cornerRadius = coverHeight / 2
        self.selectedLabelMaskView.layer.cornerRadius = coverHeight / 2
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        self.addGestureRecognizer(gestureRecognizer)
        self.selectedIndex = 0
    }
}

// MARK: - Actions & UI Changes
extension HorizontalScrollSegmentedControl {
    private func didSelectIndex() {
        let selectedLabel = self.titleLabels[self.selectedIndex]
        
        let offsetX = min(max(0, selectedLabel.center.x - self.bounds.width / 2),
                          max(0, self.scrollView.contentSize.width - self.bounds.width))
        self.scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        
        var frame = self.selectedIndicatorView.frame
        frame.origin.x = selectedLabel.frame.origin.x
        frame.size.width = selectedLabel.frame.size.width
        UIView.animate(withDuration: 0.2, animations: {
            self.selectedIndicatorView.frame = frame
            self.selectedLabelMaskView.frame = frame
        })
        
        self.sendActions(for: UIControlEvents.valueChanged)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let tapX = recognizer.location(in: self).x + self.scrollView.contentOffset.x
        
        for (i, label) in self.titleLabels.enumerated() {
            if tapX <= label.frame.maxX && tapX >= label.frame.minX {
                self.selectedIndex = i
                return
            }
        }
    }
}
