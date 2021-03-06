//
//  ContentEnumerations.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ContentEnumerations: NSObject {
    override init() {
        super.init()
        /******************* 1，枚举语法(Enumerations Syntax) *******************/
        /*
         1,和C语言不同的是，初始化枚举没有默认类型，枚举可以被定义为Int,Double,String类型
         2,初始化枚举如CompassPoint,此枚举就是CompassPoint类型。
         3,变量被声明为具体枚举类型之后可以用简短点语法
         */
        enum CompassPoint: Int{
            case west = 1, east, north, sourth
        }

        enum Season: String {
            case Spring
            case Summner
            case Autumn
            case Winter
        }

        let summ = Season(rawValue: "Spring")
        print(summ)

        /******************* 2，(Matching Enumeration Values with a Switch Statement)*******************/
        //--枚举值匹配和Switch语句
        if let sum = summ{
            switch sum {
            case .Spring:
                print("春天")
            case .Summner:
                print("夏天")
            case .Autumn:
                print("秋天")
            case .Winter:
                print("冬天")
            }
        }

        /******************* 3，关联值(Associated Values) *******************/
        enum BarCode{
            case upca(Int,Int,Int,Int)
            case qrCode(String)
        }

        var productBar = BarCode.upca(0,288,388,0)
        print(productBar)
        productBar = .qrCode("123456")
        print(productBar)

        switch productBar {
        case let .upca(numberSystem,manufacturer,product,check):
            print("\(numberSystem),\(manufacturer),\(product),\(check)")
        case let .qrCode(code):
            print("\(code)")
        default:
            print("End")
        }

        /******************* 4，原始值(Raw Values) *******************/
        /*原始值可以是字符串，字符，或者任意整型值或浮点型值。每个原始值在枚举声明中必须是唯一的。
         注意
         原始值和关联值是不同的。原始值是在定义枚举时被预先填充的值，像上述三个 ASCII 码。对于一个特定的枚举成员，它的原始值始终不变。关联值是创建一个基于枚举成员的常量或变量时才设置的值，枚举成员的关联值可以变化。
         */
        //(1),原始值的隐式赋值,访问原始值
        enum Genders: Int {
            case male = 1, female
        }

        print(CompassPoint.west.rawValue)
        print(Season.Autumn.rawValue)

        //(2),原始值得初始化
        let west = CompassPoint(rawValue: 1)
        print(west)
        // west is a "optional value"

        /******************* 5，枚举的递归(Recursive Enumerations) *******************/
        // indirect 表示可递归枚举
        indirect enum Math {
            case number(Int)
            case addition(Math,Math)
            case multiplication(Math,Math)
        }

        func evaluate(_ math: Math) -> Int{
            switch math {
            case let .number(value):
                return value;
            case let .addition(left,right):
                return evaluate(left) + evaluate(right)
            case let .multiplication(left,right):
                return evaluate(left) * evaluate(right)
            }
        }

        var sum = Math.addition(.number(4), .number(5))
        print(evaluate( sum) )
        sum = Math.multiplication(.number(9), .number(8))
        print(evaluate( sum) )
    }
}
