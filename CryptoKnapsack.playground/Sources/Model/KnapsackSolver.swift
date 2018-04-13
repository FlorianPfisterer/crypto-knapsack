import Foundation

/// Takes one Knapsack Instance and then can execute KnapsackAlgorithms on it (animated)
public class KnapsackSolver {
    private let instance: KnapsackInstance
    private let animationDelay: TimeInterval
    private let initialDelay: TimeInterval
    
    public init(instance: KnapsackInstance, withDelay delay: TimeInterval, initialDelay: TimeInterval = 0) {
        self.instance = instance
        self.animationDelay = delay
        self.initialDelay = initialDelay
    }
    
    public func startAlgorithm(_ algorithm: KnapsackAlgorithm) {
        self.instance.reset()
        
        let result = algorithm.solve(items: self.instance.items, maxSize: self.instance.maxSize)
        for (index, id) in result.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.initialDelay + TimeInterval(index) * self.animationDelay, execute: {
                self.instance.addItem(withId: id)
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + self.initialDelay + TimeInterval(result.count - 1) * self.animationDelay, execute: {
            self.instance.finished()
        })
    }
}

