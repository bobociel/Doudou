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
            case .Operation:
                let contentOperators = ContentOperators.init()
                print(contentOperators)
            case .StringAndCharacters:
                let contentString = ContentStringAndCharacters.init()
                print(contentString)
            case .CollectionTypes:
                let contentCollectionTypes = ContentCollectionTypes.init()
                print(contentCollectionTypes)
            case .ControlFlow:
                let contentControlFlow = ContentControlFlow.init()
                print(contentControlFlow)
            case .Functions:
                let contentFunctions = ContentFunction.init()
                print(contentFunctions)
            case .Closures:
                let contentClosures = ContentClosures.init()
                print(contentClosures)
            case .Enumerations:
                let contentEnumrations = ContentEnumerations.init()
                print(contentEnumrations)
            case .ClassAndStrutures:
                let contentClassAndStrutures = ContentClassesAndStructures.init()
                print(contentClassAndStrutures)
            case .Properties:
                let contentProperties = ContentProperties.init()
                print(contentProperties)
            case .Methods:
                let contentMethods = ContentMethods.init()
                print(contentMethods)
            case .Subscripts:
                let contentSubscripts = ContentSubscripts.init()
                print(contentSubscripts)
            case .Inheritance:
                let contentInheritance = ContentInheritance.init()
                print(contentInheritance)
            case .Initialization:
                let contentInitialization = ContentInitialization.init()
                print(contentInitialization)
            case .Deinitialization:
                let contentDeinitialization = ContentDeinitialization.init()
                print(contentDeinitialization)
            default:
                print("default end")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
