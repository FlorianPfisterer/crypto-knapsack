import Foundation

/// Represents a generic Knapsack item
public protocol Item: CustomStringConvertible {
    var size: UInt { get }
    var profit: UInt { get }
    var id: Int { get }
}
