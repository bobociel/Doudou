//
//  ContentAdvancedOperators.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ContentAdvancedOperators: NSObject {
    override init() {
        super.init()

        /******************* 1，位运算符(Bitwise Operators) *******************/
        //(1),按位取反位运算符(Bitwise Not Operator)
        let bitNumber = 0o00001111
        let notBitNumber = ~bitNumber
        print(bitNumber,notBitNumber)
        //(2),按位与运算符(Bitwise And Operator)
        let andBitNumber = bitNumber & 0o00000011
        print(andBitNumber)
        //(3),按位或运算符(Bitwise Or Operator)
        let orBitNumber = bitNumber | 0o00001100
        print(orBitNumber)
        //(4),按位异或运算符(Bitwise XOR Operator)
        let xorBitNumber = bitNumber ^ 0o00001111
        print(xorBitNumber)
        //(5),按位左移、右移运算符
        //①,有符号整型移位
        let leftBitNumber = bitNumber<<1
        let rightBitNumber = bitNumber>>1
        print(leftBitNumber,rightBitNumber)
        //②,无符号整型移位
        let leftBitNum = 0o11110000<<1
        let rightBitNum = 0o11110000>>1
        print(leftBitNum,rightBitNum)
        /******************* 2，(溢出操作)Overflow Operators *******************/
        //(1),溢出加法(Overflow addition (&+))
        let overflowAdd = UInt16.max &+ 1
        print(overflowAdd)
        //(2),溢出减法(Overflow subtraction (&-))
        let overflowSub = UInt16.min &- 1
        print(overflowSub)
        //(3),溢出乘法(Overflow multiplication (&*))
        let overflowMutip = UInt16.max &* 20
        print(overflowMutip)

        /******************* 3，(优先级和结合)Precedence and Associativity *******************/
        //http://wiki.jikexueyuan.com/project/swift/chapter3/04_Expressions.html

        /******************* 4，(运算符函数)Operator Functions *******************/
        









        /******************* 5， Custom Operators *******************/
    }
}
