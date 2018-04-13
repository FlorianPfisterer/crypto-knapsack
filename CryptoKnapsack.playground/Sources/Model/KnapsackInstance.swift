import Foundation

public protocol KnapsackRuntime {
    func reset()
    func addItem(withId id: Int)
    func finished()
    
    func addAlgorithm(_ algorithm: KnapsackAlgorithm)
}

public protocol KnapsackInstance: KnapsackRuntime {
    var items: [Item] { get }
    var maxSize: UInt { get }
}
