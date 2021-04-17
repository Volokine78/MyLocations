import UIKit

var str = "Hello, playground"

var count: Int
var shouldRemind: Bool
var text: String
//var list: [ChecklistItem]


var f: Float
//f = i
f = Float(i)

var i = 10
var d = 3.14
var b = true
var s = "Hello, world"
var g: Float = 3.14

class MyObject {
    var count = 0
    
    func myMethod() {
        var temp: Int
        temp = count
        print(temp)
    }
}

class MyObject2 {
    var count = 7
    
    func myMethod() {
        let count = 42
        print(self.count)
        print(count)
    }
}

let a = MyObject2()
a.myMethod()

let pi = 3.141592
//pi = 3

var ages: Dictionary<String, Int>
var ages2: [String: Int]
ages = [String: Int]()

func performUselessCalculation(_ a: Int) -> Int {
    let b = Int(arc4random_uniform(100))
    let c = a / 2
    return (a + b) * c
}

let result = performUselessCalculation(314)
print(result)

class MyObject3 {
    var numbers = [Int]()
    
    func sumValuesFromArray() -> Int {
        var total = 0
        for number in numbers {
            total += number
        }
        return total
    }
    
    func sumValues(from array: [Int]) -> Int {
        var total = 0
        for number in array {
            total += number
        }
        return total
    }
}
let j = MyObject3()
j.sumValues(from: [2, 3, 4, 5])

for i in stride(from: 0, to: 5, by: 1) {
    print(i)
}

for i in stride(from: 6, to: 0, by: -1) {
    print(i)
}
