//
//  NSObject+ClassName.swift
//  DocumentReader-Swift
//
//  Created by Pavel Kondrashkov on 9/13/21.
//  Copyright © 2021 iPass. All rights reserved.
//

import Foundation
import DocumentReader

protocol HasClassName {
    static var className: String { get }
    var className: String { get }
}

extension HasClassName {
    static var className: String {
        String(describing: self)
    }

    var className: String {
        type(of: self).className
    }
}

extension NSObject: HasClassName {}




