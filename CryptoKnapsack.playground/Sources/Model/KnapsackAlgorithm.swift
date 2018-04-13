import Foundation

public protocol KnapsackAlgorithm {
    /// Solves the given Knapsack problem instance
    ///
    /// - Parameters:
    ///   - items: an arry of all available items in this instance
    ///   - maxSize: the maximum allowed size for the selected items
    /// - Returns: the item ids that are selected by the algorithm. Must be a subset of the indexes of the given items
    func solve(items: [Item], maxSize: UInt) -> [Int]
    
    /// The name of the algorithm, used to distinguish the algorithm from others
    var displayName: String { get }
}
