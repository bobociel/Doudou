//
//  ContentViewController.swift
//  Swift3
//
//  Created by wangxiaobo on 16/7/8.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

import UIKit

enum ContentType {
    case ContentTypeTheBasics
    case ContentTypeOperation
    case ContentTypeStringAndCharacters
    case ContentTypeCollectionTypes
    case ContentTypeControlFlow
    case ContentTypeFunctions
    case ContentTypeClosures
    case ContentTypeEnumerations
    case ContentTypeClassAndStrutures
    case ContentTypeProperties
    case ContentTypeMethods
    case ContentTypeSubscripts
    case ContentTypeInheritance
    case ContentTypeInitialization
    case ContentTypeDeinitialization
    case ContentTypeARC
    case ContentTypeOptionalChaining
    case ContentTypeErrorHandling
    case ContentTypeTypeCasting
    case ContentTypeNestedTypes
    case ContentTypeExtensions
    case ContentTypeProtocols
    case ContentTypeGenerics
    case ContentTypeAccessControl
    case ContentTypeAdvancedOperators
}

class ContentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ContentTheBasics.init()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
