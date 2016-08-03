//
//  ContentTypeCasting.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/13.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

class ContentTypeCasting: NSObject {
    override init(){
        super.init()
        /******************* 1，定义类层次和类型转换(Defining a Class Hierarchy for Type Casting) *******************/
        class MediaItem{
            var name: String
            init(name: String){
                self.name = name;
            }
        }

        class Movie: MediaItem {
            var director: String
            init(name: String, director: String){
                self.director = director
                super.init(name: name)
            }
        }

        class Song: MediaItem{
            var artist: String
            init(name: String, artist: String) {
                self.artist = artist;
                super.init(name: name)
            }
        }

        let lib = [
            Movie(name: "英雄", director: "张艺谋"),
            Movie(name: "疯狂的石头", director: "宁浩"),
            Song(name: "英雄", artist: "SHE"),
            Song(name: "她说", artist: "林俊杰"),
            Song(name: "你不是真正的快乐", artist: "五月天")
        ]

        print(lib)
        /******************* 2，类型检查(Checking Type) *******************/
        for item in lib{
            if item is Movie{
                print("\(item): is Movie")
            }else if item is Song{
                print("\(item): is Song")
            }
        }

        /******************* 3，向下转型(Downcasting) *******************/
        for item in lib{
            if let movie = item as? Movie{
                print("Movie:\(movie.name): by \(movie.director)")
            }else if let song = item as? Song{
                print("Song:\(song.name): by \(song.artist)")
            }
        }

        /******************* 4，Any和AnyObject类型转换(Type Casting for Any and AnyObject) *******************/
        //1: AnyObject可以代表任何class类型的实例。
        //2: Any可以表示任何类型，包括方法类型（function types）。

        let someObjects: [AnyObject] = [
            Movie(name: "英雄", director: "张艺谋"),
            Movie(name: "疯狂的石头", director: "宁浩")
        ]

        //注意：因为知道这个数组只包含 Movie 实例，你可以直接用(as)下转并解包到不可选的Movie类型（ps：其实就是我们常用的正常类型，这里是为了和可选类型相对比）。
        for movie in someObjects as! [Movie]{
            print("Movie:\(movie.name):\(movie.director)")
        }

        let tuple = (httpCode:404,httpMessgae:"Not Found")

        var things = [Any]()
        things.append(1)
        things.append(12.0)
        things.append(Float(13.0))
        things.append("String")
        things.append( [1,2,3] )
        things.append( ["1":1,"2":2,"3":3] )
        things.append( [tuple] )
        things.append(Movie(name: "星球", director: "Unknow"))
        things.append( { (name: String) -> (String) in "Hello,\(name)"  } )

        for thing in things{
            switch thing {
            case let someInt as Int:
                print("Int:\(someInt)")
            case let someDouble as Double:
                print("Double:\(someDouble)")
            case let someString as String:
                print("String:\(someString)")
            case let someArray as [Int]:
                print("Array:\(someArray)")
            case let someDict as [String: Int]:
                print("Dictionary:\(someDict)")
            case let someObject as Movie:
                print("Object:\(someObject)")
            case let someFuc as (String) -> String:
                print("Function:\(someFuc)")
            default:
                print("some thing other")
            }
        }

    }
}
