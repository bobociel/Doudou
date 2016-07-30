//
//  ContentNestedTypes.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ContentNestedTypes: NSObject {
    override init() {
        super.init()
        /******************* 1，嵌套类型的实例(Nested Types in Action) *******************/
        //1, 枚举类型常被用于实现特定类或结构体的功能。也能够在有多种变量类型的环境中，方便地定义通用类或结构体来使用，为了实现这种功能，Swift允许你定义嵌套类型，可以在枚举类型、类和结构体中定义支持嵌套的类型。
        //2, 要在一个类型中嵌套另一个类型，将需要嵌套的类型的定义写在被嵌套类型的区域{}内，而且可以根据需要定义多级嵌套。
        enum Season{
            case Spring
            case Summer
            case Autumn
            case Winter

            enum WeekDay{
                case Monday, Sunday
            }

            struct Sky{
                var color: UIColor = UIColor.whiteColor()
            }

            class Rain{
                var tem: Double = 27.0
            }
        }

        struct Car{
            enum CarType {
                case Small
                case Big
            }

            struct Wheel {
                var radius: Double = 200
            }

            class Body {
                var deskNum: Double = 4
                init(deskNum: Double){
                    self.deskNum = deskNum
                }
            }
        }

        class Person{
            enum Gender{
                case Male, Female
            }

            struct Size {
                var height: Double = 0
                var weight: Double = 45
            }

            class Body {
                var shap: String = "Circle"
                init(shap: String){
                    self.shap = shap
                }
            }
        }

        /******************* 2，嵌套类型的引用(Referring to Nested Types) *******************/
        let seasonEnum = Season.WeekDay.Monday
        let seasonStruct = Season.Sky(color: UIColor.redColor())
        let seasonClass = Season.Rain()
        seasonClass.tem = 30

        let carEnum = Car.CarType.Big
        let carStruct = Car.Wheel.init(radius: 300)
        let carClass = Car.Body.init(deskNum: 6)

        let personEnum = Person.Gender.Female
        let personStruct = Person.Size(height: 160, weight: 40)
        let personClass = Person.Body(shap: "Circle")

        print("\(seasonEnum),\(seasonStruct.color)色的天空有大大的☀️，空气温度是\(seasonClass.tem) \n 路边有个\(carEnum)🚗，车的轮子半径有\(carStruct.radius)，车上面有\(carClass.deskNum)个💺,其中一个💺上是位\(personEnum)性🚺,身高\(personStruct.height)有个\(personClass.shap)的肚子")
    }
}
