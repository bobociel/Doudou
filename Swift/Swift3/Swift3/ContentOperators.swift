//
//  ContentOperators.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit
/*术语:Terminology
 Operators are unary,binary,ternary 运算符有三种：一元运算符，二元运算符，三元运算符
 example: +a, a + b , a ? 1 : 2
*/
class ContentOperators: NSObject {
    override init() {
        super.init()

        /******************* 1，赋值运算符(assignment operator) *******************/
        let assignOperator = "assignment operator: ="
        print(assignOperator)

        /******************* 2，算术运算符(arithmetic operators) *******************/
        print("arithmetic operators: +,-,*,/,%")
        print("umary minus operator: -")
        print("umary plus operator: +")

        /******************* 3，算术运算符(compound assigment operators) *******************/
        print(" a += 2, b -= 1")

        /******************* 4，比较运算符(comparision assigment operators) *******************/
        print("a == b, a != b, a > b, a < b, a >= b, a <= b ")
        print("(1,\"apple\") > (2,\"pear\") ")

        /******************* 5，三元条件运算符(ternary conditional operators) *******************/
        print(" a = true ? 10 : 20")
        print(" var a ?? b ")

        /******************* 6，区间运算符(range operators) *******************/
        //Closed Operator
        for n in 1...4 { print(n) }
        //half-open Operator
        for n in 1..<3 { print("n=",n) }

        /******************* 7，逻辑运算符(Logical operators) *******************/
        print("!a")
        print("a && b")
        print("a || b")
        print("a && b || c || d")
        print("(a && b) || (c && d)")
    }
}
