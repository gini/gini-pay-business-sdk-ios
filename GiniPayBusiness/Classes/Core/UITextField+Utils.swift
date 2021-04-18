//
//  UITextField+Utils.swift
//  GiniPayBusiness
//
//  Created by Nadya Karaban on 18.04.21.
//

import Foundation
public extension UITextField {
    var isReallyEmpty: Bool {
        return text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true
    }
}
