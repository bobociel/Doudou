//
//  ContentViewController.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

enum  ContentType: Int {
    case TheBasics
    case Operation
    case StringAndCharacters
    case CollectionTypes
    case ControlFlow
    case Functions
    case Closures
    case Enumerations
    case ClassAndStrutures
    case Properties
    case Methods
    case Subscripts
    case Inheritance
    case Initialization
    case Deinitialization
    case ARC
    case OptionalChaining
    case ErrorHandling
    case TypeCasting
    case NestedTypes
    case Extensions
    case Protocols
    case Generics
    case AccessControl
    case AdvancedOperators
}

class ContentViewController: UIViewController {
    var _contentType: ContentType?
    var contentType: ContentType? { get{return _contentType;} set(type){
        _contentType = type
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if _contentType != nil{
            switch _contentType! {
            case .TheBasics:
                let contentTheBasics = ContentTheBasics.init()
                print(contentTheBasics)
            default:
                print("default end")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
