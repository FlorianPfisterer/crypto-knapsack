/*:
 # CryptoKnapsack

 ### Welcome to the CryptoKnapsack playground!

 Here, you can explore the [Knapsack Problem](https://en.wikipedia.org/wiki/Knapsack_problem) - a famous optimization problem in computer science.
 
 Please make sure you open the playground's Assistant Editor so you can use the visual representation of the playground.
*/
import UIKit
import PlaygroundSupport
//: Let's first define the playground's `liveView` with a little inset so we have a nice border.
let margin: CGFloat = 15
let frame = CGRect(x: 0, y: 0, width: 500, height: 800)
let container = UIView(frame: frame)
container.backgroundColor = .white

let knapsack = KnapsackContainerView(frame: frame.insetBy(dx: margin, dy: margin))
container.addSubview(knapsack)

PlaygroundPage.current.liveView = container
/*:
 That's it - now you can explore the **Knapsack Problem** in the Assistant Editor on the right.
 Once you have gotten a feeling for the problem, come back and check out some popular algorithms that solve it.
 
 In the end, you can write your own - and have the chance to win $1 million (see the playground description essay for details 🤓).

 ### Algorithm #1: The Greedy Algorithm
 
 First, we define an extension that will come handy once we write the algorithm.
*/
extension Item {
    var profitDensity: Double {
        return Double(self.profit) / Double(self.size)
    }
}
/*:
 The **Greedy Algorithm** always makes the *locally optimal choice* at each point.
 
 Though it is very fast: `O(nlog(n))` (`n` being the number of items or coins) - it does not always give us an optimal solution.
 */
final class GreedyAlgorithm: KnapsackAlgorithm {
    let displayName: String = "Greedy"
    
    func solve(items: [Item], maxSize: UInt) -> [Int] {
        // sort the items by decreasing profit density
        let sorted = items.sorted(by: { $0.profitDensity > $1.profitDensity })
        
        // try to add the items in this order
        var ids: [Int] = []
        var restSize: UInt = maxSize
        var i = 0
        while restSize > 0 && i < sorted.count {
            // if there's still room for the next item, add it
            // (it has the maximum profit density still available)
            if sorted[i].size <= restSize {
                restSize -= sorted[i].size
                ids.append(sorted[i].id)
            }
            i += 1
        }
        
        return ids
    }
}

//: Now all we have to do is add it to our live view. Select the 'Greedy' algorithm and run it to see it in action!
knapsack.addAlgorithm(GreedyAlgorithm())
/*:
 ### Algorithm #2: Dynamic Programming

 The **Dynamic Programming Algorithm** *does* give us an optimal solution, but it is only pseudo-polynomial.
 
 This means that its time complexity is `O(maxSize * n)` (`maxSize` being the capacity of the knapsack).
 
 You can check out my Swift implementation by Cmd-clicking the class name below.
 */
knapsack.addAlgorithm(DynamicProgrammingAlgorithm())
/*:
 ### Algorithm #3: Your Own!
 
 Now it's time to write your own algorithm!
 Implement the `solve()` method, give it a name and add it to the knapsack - it will appear on the right.
 
 Have fun! 😃
 */
final class CustomAlgorithm: KnapsackAlgorithm {
    let displayName: String = "Custom"
    
    func solve(items: [Item], maxSize: UInt) -> [Int] {
        // TODO: implement an optimal and deterministic polynomial-time algorithm for the Knapsack Problem
        // (and earn $1 million!)
        return []
    }
}

knapsack.addAlgorithm(CustomAlgorithm())
