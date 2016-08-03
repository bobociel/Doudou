//
//  ContentClosures.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ContentClosures: NSObject {
    override init() {
        super.init()
        /******************* 1，闭包表达式(closure expressions) *******************/
        //(1),sort方法(The Sort Method)
        let names = ["魔女","刘备","李白","牛魔王","孙悟空"]
        func compareString(_ aName: String,bName: String) -> Bool{
            return aName > bName
        }

        print( names.sorted(by: compareString) )

        //(2),闭包表达式语法(Closure Expression Syntax)
        /*
             {(parameter) -> returnValue in
                 statement
             }
        */
        print( names.sorted( by: {(aName:String, bName:String) -> Bool in return aName > bName} ) )

        //(3),根据上下文推断类型(Inferring Type from Context)
        print( names.sorted( by: { s1, s2 in return s1 > s2} ) )

        //(4),单表达式闭包隐式返回(Implicit Return From Single-Expression Clossures)
        print( names.sorted( by: {s1,s2 in s1 > s2} ) )

        //(5),参数名缩写(Shorthand Argument Names)
        print( names.sorted( by: {$0 > $1 }) )

        //(6),运算符函数
        print( names.sorted(by: >) )

        /******************* 2，追尾闭包(Trailing Closures) *******************/
        /*If you need to pass a closure expression to a function as the function’s final argument and the closure expression is long, it can be useful to write it as a trailing closure instead. A trailing closure is written after the function call’s parentheses, even though it is still an argument to the function. When you use the trailing closure syntax, you don’t write the argument label for the closure as part of the function call.
         */

        func someFunctionThatTakesAClosure(_ closure: () -> Void) {
            // function body goes here
        }

        //someFunctionThatTakesAClosure(closure: {  //Swift3
        someFunctionThatTakesAClosure( {
            // closure's body goes here
        })

        someFunctionThatTakesAClosure() {
            // trailing closure's body goes here
        }
        //use trailing cloaure
        print( names.sorted(){$0 > $1} )
        //如果函数只需要闭包表达式一个参数，当您使用尾随闭包时，您甚至可以把()省略掉：
        print( names.sorted{$0 > $1} )

        /******************* 3，值(Capture Values) *******************/
        func makeIncrease(increase amount: Int) -> () -> Int{
            var sum: Int = 0
            func increase() -> Int{
                sum += amount
                return sum;
            }
            return increase;
        }

        let increateTen = makeIncrease(increase: 10)
        print( increateTen() )
        print( increateTen() )

        let increateSenven =  makeIncrease(increase: 7)
        print(increateSenven() )
        print(increateSenven() )

        let increate10 = makeIncrease(increase: 10)
        print( increate10() )
        print( increate10() )

        /******************* 4，闭包是引用类型(Closures Are Reference Value) *******************/
        print( increateTen() )

        /******************* 5，非逃逸闭包(Nonescaping Closures) *******************/
        

        /******************* 6，自动闭包(Auto Closures) *******************/
//        自动闭包，顾名思义是一种自动创建的闭包，用于包装函数参数的表达式，可以说是一种简便语法。
//        自动闭包不接受任何参数，被调用时会返回被包装在其中的表达式的值。
        var arry = ["1","2","3","4","5"]
        let removeArray = { arry.removeLast() }
        print(arry)

        removeArray()
        print(arry)
    }
}
