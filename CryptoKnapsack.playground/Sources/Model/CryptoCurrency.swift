import Foundation
import UIKit

/// Specific type of Knapsack item that represents a cryptocurrency. The size here is the blockchain size, and the profit is the value per coin.
public class CryptoCurrency: Item {
    public let id: Int
    public let symbol: String
    public let profit: UInt
    public let size: UInt
    
    init(id: Int, symbol: String, price: UInt, size: UInt) {
        self.id = id
        self.symbol = symbol
        self.profit = price
        self.size = size
    }
    
    public var description: String {
        return self.symbol
    }
}

// The coin prices and blockchain sizes will probably be different by now. These values have been last updated on March 29, 2018.
// Note that some of the most popular cryptocurrencies have been left out, because their price and blockchain are too big compared
// to the other currencies - and that would make the Knapsack Problem a bit boring.
// Sources: https://bitinfocharts.com and https://coinmarketcap.com. Some sizes are estimated based on block count and block size.
private let ethClassic  = CryptoCurrency(id: 0, symbol: "ETC",  price: 16,   size: 64)                                  // 31% of total size
private let neo         = CryptoCurrency(id: 1, symbol: "NEO",  price: 54,   size: 40)  // estimated blockchain size    // 19% of total size
private let zcash       = CryptoCurrency(id: 2, symbol: "ZEC",  price: 199,  size: 12)                                  // 5.8% of total size
private let veritaseum  = CryptoCurrency(id: 3, symbol: "VERI", price: 138,  size: 30)  // estimated blockchain size    // 14.4% of total size
private let monero      = CryptoCurrency(id: 4, symbol: "XMR",  price: 190,  size: 45)                                  // 21.7% of total size
private let litecoin    = CryptoCurrency(id: 5, symbol: "LTC",  price: 123,  size: 16)                                  // 7.7% of total size
// sum: 207 GB

public struct ItemInfo {
    public let item: Item
    public let frame: CGRect
    
    public static let all: [ItemInfo] = [
        ItemInfo(item: ethClassic,      frame: CGRect(x: 0,     y: 0,   width: 175, height: 175)),
        ItemInfo(item: neo,             frame: CGRect(x: 130,   y: 180, width: 138, height: 138)),
        ItemInfo(item: zcash,           frame: CGRect(x: 20,    y: 220, width: 78,  height: 78)),
        ItemInfo(item: veritaseum,      frame: CGRect(x: 210,   y: 30,  width: 120, height: 120)),
        ItemInfo(item: monero,          frame: CGRect(x: 320,   y: 150, width: 147, height: 147)),
        ItemInfo(item: litecoin,        frame: CGRect(x: 360,   y: 0,   width: 87,  height: 87))
    ]
}

