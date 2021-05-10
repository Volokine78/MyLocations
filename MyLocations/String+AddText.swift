//
//  String+AddText.swift
//  MyLocations
//
//  Created by Tolga PIRTURK on 10.05.2021.
//

import Foundation

extension String {
    mutating func add(text: String?, separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}
