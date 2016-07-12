//
//  ContentSubscripts.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ContentSubscripts: NSObject {
    override init() {
        super.init()
        /******************* 1，下标语法(Subscript Syntax) *******************/
        /*Subscripts enable you to query instances of a type by writing one or more values in square brackets after the instance name. Their syntax is similar to both instance method syntax and computed property syntax. You write subscript definitions with the subscript keyword, and specify one or more input parameters and a return type, in the same way as instance methods. Unlike instance methods, subscripts can be read-write or read-only. This behavior is communicated by a getter and setter in the same way as for computed properties:*/

        /*
         subscript(index: Int) -> Int {
            get {
                // return an appropriate subscript value here
            }
            set(newValue) {
                // perform a suitable setting action here
            }
         }
         */

        /*As with read-only computed properties, you can drop the get keyword for read-only subscripts:
         subscript(index: Int) -> Int {
             // return an appropriate subscript value here
         }
         */

        /******************* 2，下标用法(Subscript Usage) *******************/
        struct Subscript{
            var number: Int
//            subscript(index: Int) -> Int{
//                return number * index
//            }
            subscript(index: Int) -> Int{
                get{
                    return number * index
                }
                set(newValue){
                    self.number = newValue
                }
            }
        }

        var sub = Subscript(number: 12)
        sub[3] = 10
        print(sub[2],sub[3])

        /******************* 3，下标选项(Subscript Options) *******************/
        //TODO
    }
}
