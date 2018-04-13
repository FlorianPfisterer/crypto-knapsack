import Foundation

/// Uses Dynamic Programming to solve the Knapsack Problem. Runs in pseudo-polynomial time, but provides an optimal solution)
public final class DynamicProgrammingAlgorithm: KnapsackAlgorithm {
    public init() { }
    
    public let displayName: String = "Dynamic Programming"
    
    public func solve(items: [Item], maxSize: UInt) -> [Int] {
        let n = items.count
        
        /* Define an array 'profits' of arrays of UInt, that has dimension (n+1 x maxSize+1)
         * for p = profits[ i ][ s ]:
         * let 'p' be the maximum profit that we can make
         * using only items with their id in 0...i
         * with the total size necessary <= 's'
         */
        let profitArray = [UInt](repeating: 0, count: Int(maxSize + 1))
        var profits = [[UInt]](repeating: profitArray, count: n+1)
        
        let falseArray = [Bool](repeating: false, count: Int(maxSize + 1))
        var decisions = [[Bool]](repeating: falseArray, count: n+1)
        
        // find out the optimal profit for each (i, s) pair and save in 'decisions' which item we take
        for i in 1...n {
            let item = items[i - 1]
            
            for s in 0...Int(maxSize) {
                var p: UInt = 0
                let remainingSize: Int = s - Int(item.size)
                if remainingSize >= 0 {
                    p = profits[i-1][remainingSize] + item.profit
                }
                
                // find out if we should use item (i-1) or not
                if p > profits[i-1][s] {
                    profits[i][s] = p
                    decisions[i][s] = true
                } else {
                    profits[i][s] = profits[i-1][s]
                }
            }
        }
        
        // let's find out which ids we have to choose to achieve this optimal profit
        var s: UInt = maxSize
        var ids = [Int]()
        for i in (1...n).reversed() {
            if decisions[i][Int(s)] {
                ids.append(i - 1)
                s -= items[i - 1].size
            }
        }
        
        return ids
    }
}
