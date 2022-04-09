//
//  Extensions.swift
//  Wharrgarbl
//
//  Created by Philipp Brendel on 01.04.22.
//

import Foundation

extension StringProtocol {
    subscript(offset: Int) -> String {
        String(self[index(startIndex, offsetBy: offset)])
    }
    
    func explode() -> [String] {
        self.map {String($0)}
    }
}
