//
//  NSObjectHelpers.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import Foundation

extension NSObject {
    var className: String {
        String(describing: type(of: self))
    }
}
