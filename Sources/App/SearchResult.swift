//
//  SearchResult.swift
//  Wharrgarbl
//
//  Created by Philipp Brendel on 02.04.22.
//

import Foundation

struct SearchResult {
    let word: String
    let score: Int
    let hints: [Letter: Hint]
}
