import UIKit
import AVFoundation

private let colorWheelSpacing: CGFloat = 10

class CircularSliderControl: UIControl {
    // MARK: - Public Configuration
    var maxValue: UInt = 7 {     // 2^7 = 128 GB
        didSet { self.updateLabel() }
    }
    var minValue: UInt = 4 {     // 2^4 = 16 GB
        didSet { self.updateLabel() }
    }
    var unit: String = "GB" {
        didSet { self.updateLabel() }
    }
    
    private(set) var value: UInt = 0 {
        didSet { self.valueChanged() }
    }
    
    private var avPlayer: AVAudioPlayer?
    
    // MARK: - Subviews & Gestures
    private let colorWheel: MultiColorWheelView = {
        let wheel = MultiColorWheelView()
        wheel.translatesAutoresizingMaskIntoConstraints = false
        wheel.backgroundColor = .clear
        return wheel
    }()
    
    private let capacityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.font = UIFont(name: "Menlo", size: 21) ?? .systemFont(ofSize: 21, weight: .light)
        return label
    }()
    
    private let rotationRecognizer = AngleGestureRecognizer()
    private var transformAtStartOfGesture: CGAffineTransform?
    
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
        self.addSubview(self.colorWheel)
        self.addSubview(self.capacityLabel)
        
        self.colorWheel.constrainToEdges(of: self, spacing: colorWheelSpacing)
        self.capacityLabel.constrainToCenter(of: self)
        
        self.colorWheel.colorDelegate = self
        self.colorWheel.arcWidth = 15
        
        self.updateLabel()
        
        self.addGestureRecognizer(self.rotationRecognizer)
        self.rotationRecognizer.addTarget(self, action: #selector(self.rotationChanged))
        
        // create selection rectangle
        let selectedSegmentView = UIView()
        selectedSegmentView.translatesAutoresizingMaskIntoConstraints = false
        selectedSegmentView.backgroundColor = .clear
        selectedSegmentView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        selectedSegmentView.layer.borderWidth = 1.5
        selectedSegmentView.layer.cornerRadius = 2
        self.addSubview(selectedSegmentView)
        
        selectedSegmentView.centerXAnchor.constraint(equalTo: self.centerXAnchor).activate()
        selectedSegmentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).activate()
        selectedSegmentView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.05).activate()
        selectedSegmentView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.22).activate()
        
        self.setupAudioPlayer()
        
        // add initial rotation
        let transform = CGAffineTransform(rotationAngle: π * 3/2)
        self.transformAtStartOfGesture = transform
        self.colorWheel.transform = transform
        self.updateLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.colorWheel.setNeedsDisplay()
    }
    
    private func setupAudioPlayer() {
        guard let clickFile = Bundle.main.url(forResource: "wheel-click", withExtension: "wav") else {
            return
        }
        
        do {
            self.avPlayer = try AVAudioPlayer(contentsOf: clickFile)
            self.avPlayer?.prepareToPlay()
        } catch {
            debugPrint("Error while creating audio player: \(error)")
            return
        }
    }
    
    @objc func rotationChanged() {
        let delta = self.rotationRecognizer.angleDelta
        switch self.rotationRecognizer.state {
        case .began:
            self.transformAtStartOfGesture = self.colorWheel.transform
        case .changed:
            self.colorWheel.transform = self.transformAtStartOfGesture?.rotated(by: delta) ?? CGAffineTransform(rotationAngle: delta)
        default:
            self.transformAtStartOfGesture = nil
        }
        
        self.updateLabel()
    }
    
    private func valueChanged() {
        self.sendActions(for: .valueChanged)
    }
    
    private func updateLabel() {
        // calculate based on linear scale, then convert to logarithmic by using the result percentage as the exponent
        var percentage: UInt = 0
        if let angle = self.colorWheel.layer.value(forKeyPath: "transform.rotation.z") as? CGFloat {
            if angle < 0 {  // left side
                percentage = UInt((π - abs(angle) + π) / (2*π) * 100) + 1
            } else {    // right side (of life)
                percentage = UInt(angle / (2*π) * 100) + 1
            }
        } else {
            percentage = 100    // default
        }
        
        // reverse direction
        percentage = 100 - percentage
        
        let exponent = self.minValue + UInt(Double(percentage) * 0.01 * Double(self.steps))
        let capacity = UInt(pow(2, Double(exponent)))
        
        let newText = "\(capacity) \(self.unit)"
        if let oldText = self.capacityLabel.text, !oldText.isEmpty, newText != oldText {
            self.playClickSound()
        }
        
        if newText != self.capacityLabel.text {
            self.capacityLabel.text = newText
            self.value = capacity
        }
    }
    
    private var steps: UInt {
        return UInt(self.maxValue - self.minValue) + 1
    }
}

// MARK: - Sounds
extension CircularSliderControl {
    private func playClickSound() {
        self.avPlayer?.play()
    }
}

extension CircularSliderControl: ColorDelegate {
    func colorForWheel(atProportion proportion: CGFloat) -> UIColor {
        if UInt(proportion * CGFloat(MultiColorWheelView.colorSegmentCount)) % (MultiColorWheelView.colorSegmentCount / self.steps) == 0 {
            return .clear
        }
        
        return UIColor(hue: 0.5, saturation: 1, brightness: 1.1 - (0.9 * proportion), alpha: 1)
    }
}

