//: Playground - noun: a place where people can play

import UIKit
var int: Int?
var float: Float?
var double:Double?
var str: String?

print("LoveWithMe")

let int2 = 100
let float2 = 100.123
let double2: Double = 100.123456
let div = 10 / 3.0

int = 100
double = 0.4
var str2 = "世界" + String(int2)
str = "你好\(str2)"

var classes = ["A","B","C","D",12]
var students = ["紫琪":"A","安迪":"A","阿梅":"B","海棠":"C","小丽":"D","美珠":12]




let scores = [75,80,38,83,90,64,58]
for s in scores{
    if s > 60{
        print("及格")
    }else{
        print("不及格")
    }
}

var happy: String?
happy = "Happy"
if let h = happy{
    print("Big \(h)")
}

var good: String?
good = "good"
print("\(good ?? "" ) Day")

let bigDay = "big day"
switch bigDay{
    case "big":
        print("Word has big")
    case "big", "day":
        print("Word has big or day")
    case let x where x.hasSuffix("day"):
        print("Word has suffix day")
    default:
        print("Word only word")
}

for (key, value) in students{
    print("key:\(key),value:\(value)")
}

while int > 0{
    int = int! - 1
    print("\(int ?? 0)")
}

repeat{
    int = int! + 1
} while int < 100
print("\(int ?? 0)")

var total = 0
for n in 10..<20{
    total = total + n
    print("\(total)")
}



let stuAge = ("Hello",12)

func fib(m: Int) -> (Int, Int){
    var n = 0
    var a = 0
    var b = 1
    var c = 0
    while n < m {
        n = n + 1
        c = b
        b = a + b
        a = c
    }
    return (a,b);
}

fib(3)

var two: Int?
let three = two ?? 3
let four = (three == 0) ? 3 : 4


let btn = UIButton.init(frame: CGRectMake(10, 10, 100, 100));
btn.backgroundColor = UIColor.greenColor();
btn.setTitle("点击", forState: .Normal)

UIView.animateWithDuration(0.5) { 
    btn.frame = CGRectMake(10, 10, 200, 200)
};


