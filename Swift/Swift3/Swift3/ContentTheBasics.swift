//
//  ContentTheBasics.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ContentTheBasics: NSObject {

    override init() {
        super.init()
        /******************* 1,常量和变量 *******************/
        self.ConstantsAndVariables()
        /******************* 2,整型 *******************/
        self.Integers()
        /******************* 3,浮点型 *******************/
        self.FloatingPointNumbers()
        /******************* 4,类型安全和类型推断 *******************/
        self.SafeTypeAndTypeInference()
        /******************* 5,数字字面量 *******************/
        self.NumericLiterals()
        /******************* 6,类型转换 *******************/
        self.NumericTypeConversation()
        /******************* 7,类型别名 *******************/
        self.TypeAliases()
        /******************* 8,布尔 *******************/
        self.Booleans()
        /******************* 9,元组 *******************/
        self.Tuples()
        /******************* 10,可选值 *******************/
        self.Optionals()
        /******************* 11,错误处理 *******************/

        //        do {
        //            try self.ErrorHandling()
        //        }catch {
        //
        //        }

        /******************* 12,断言 *******************/
        //        self.Assertions()
    }

    func ConstantsAndVariables() {
        //1：常量和变量的初始化，命名
        let helloString = "Hello"
        let worldString = "World"
        let welcome🐍 = helloString + worldString

        let a = 2, b = 3, c = 4
        var (d,e,f) = (1,2,3)

        //2:，类型定义
        var varA: NSString; varA = "!"

        //3:注释  单行注释：// 多行注释：/* */

        //4:分号
        d = 9; e = 10; f = 12

        //5:打印
        print("[FUNCTION]:\(#function),[LINE]:\(#line)")
        print("\(welcome🐍):\(a+b+c),\(d+e+f),\(varA)")
    }

    func Integers() {
        //1:整型的最大值和最小值
        let minValue = UInt8.min
        let maxValue = UInt8.max

        //2:无符号整型的32位和64位
        let minValueUInt32 = UInt32.min
        let maxValueUInt32 = UInt32.max

        let minValueUInt64 = UInt64.min
        let maxValueUInt64 = UInt64.max

        //3:有符号整型的32位和64位
        let minValueInt32 = Int32.min
        let maxValueInt32 = Int32.max

        let minValueInt64 = Int64.min
        let maxValueInt64 = Int64.max

        print("minValue:\(minValue);maxValue:\(maxValue);")
        print("minValueUInt32:\(minValueUInt32);maxValueUInt32:\(maxValueUInt32);")
        print("minValueUInt64:\(minValueUInt64);maxValueUInt64:\(maxValueUInt64);")
        print("minValueInt32:\(minValueInt32);maxValueInt32:\(maxValueInt32);")
        print("minValueInt64:\(minValueInt64);maxValueInt64:\(maxValueInt64);")
    }

    func FloatingPointNumbers() {
        //1:浮点型 系统默认浮点型为Double
        let floatValue    = Float(3.13)
        let doubleValue   = 10.22
        print("floatValue:",floatValue,",doubleValue:",doubleValue)
    }

    func SafeTypeAndTypeInference() {
        //1:类型推断 系统自动推断未说明类型的常量或变量
        let integerValue = 3

        //2:Float转换为Double
        let floatValue    = Float(3.13)
        let doubleValue   = 10.22

        //3:常量、变量做运算时需要适当得转化类型
        let sumIntegerValue = Int(floatValue) + Int(doubleValue)
        let sumDoubleValue = Double(integerValue) + doubleValue

        print(sumIntegerValue,",",sumDoubleValue)
    }

    func NumericLiterals() {
        //1:二进制数据，八进制数据，十进制数据，十六进制数据
        let decimalInteger = 17
        let binaryInteger = 0b10001
        let octalInteger = 0o21
        let hexadecimalInteger = 0x11
        print("\(decimalInteger),\(binaryInteger),\(octalInteger),\(hexadecimalInteger)")

        //2：科学计数法(十进制浮点数可选指数、十六进制浮点数必须指数)
        let decimalDouble = 12.758
        let exponentDouble = 12.758e1
        let hexadecimalDouble = 0x1.3p2
        print("\(decimalDouble),\(exponentDouble),\(hexadecimalDouble)")

        //3：对于长度很大的数字可以使用“_”分割
        let oneMillion = 1_000_000
        let overOneMillion = 1_000_000.000_1
        print("\(oneMillion),\(overOneMillion)")
    }

    func NumericTypeConversation() {
        let integerValue: UInt8 = 12
        let integerValue16: UInt16 = 20
        let sumIntegerOne = UInt16(integerValue) + integerValue16
        let sumIntegerTwo = integerValue + UInt8(integerValue16)

        print("sumIntegerOne:\(sumIntegerOne);sumIntegerTwo:\(sumIntegerTwo)");
    }

    func TypeAliases() {
        //1:类型别名
        typealias Interger16 = Int16
        let minInt16 = Int16.min
        let minInt16_2 = Interger16.min

        print(minInt16,minInt16_2)
    }

    func Booleans() {
        //1：布尔类型
        let yes = true
        let no = false

        print("yes:\(yes);no:\(no)")
    }

    func Tuples() {
        //1：元组
        let http404Error = (404,"Not Found")
        let (statusCode, statusMessgae) = http404Error
        let http200OK = (statusCode:200,statusMessgae:"SUCCESS")

        print("\(http404Error.0),\(http404Error.1)")
        print("\(statusCode),\(statusMessgae)")
        print("\(http200OK.statusCode),\(http200OK.statusMessgae)")
    }

    func Optionals() {
        let possiableString: String = "s123"
        let possInt = Int(possiableString)
        print(possInt);

        var opetionValue: String?
        opetionValue = nil
        // if statements and forced unwrapping
        if opetionValue != nil{
            print(possInt);
        }

        //optional bindling
        if let n = opetionValue{
            print(n)
        }

        //implicitly unwrapped optional
        let possibleString: String? = "possible string"
        //        let forcedString: String = possiableString!    //cannot force unwrap

        let assumedString: String! = "assumend string"
        let implicit: String = assumedString

        print("[FUNCTION]:\(#function),[LINE]:\(#line)")
        print(possibleString!,implicit)
    }
    
    func ErrorHandling() throws{
        var zero: Int = 1
        zero = Int("0")!
        print(10 / zero)
    }
    
    func Assertions() {
        let score = 60
        assert(score > 60,"不及格")
    }
}
