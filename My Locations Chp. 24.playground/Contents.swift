import UIKit

var str = "Hello, playground"

class IceCream: NSObject {
    var flavor: String
    var scoops: Int
    
    func eatIt() {}
    
    init(flavor: String, scoops: Int) {
        self.flavor = flavor
        self.scoops = scoops
    }
}

let iceCreamForYou = IceCream(flavor: "Strawberry", scoops: 2)
iceCreamForYou.flavor
iceCreamForYou.scoops

let iceCreamForMe = IceCream(flavor: "Pistachio", scoops: 3)
iceCreamForMe.flavor
iceCreamForMe.scoops

class Snack {
    var flavor: String
    func eatIt() {}
    
    init(flavor: String) {
        self.flavor = flavor
    }
}

class IceCream2: Snack {
    var scoops: Int
    
    init(scoops: Int, flavor: String) {
        self.scoops = scoops
        super.init(flavor: flavor)
    }
    
    override func eatIt() {}
}

let iceCreamForMe2 = IceCream2(scoops: 3, flavor: "Chocolate")
iceCreamForMe2.flavor
iceCreamForMe2.eatIt()
