//
//  Hint.swift
//  Wharrgarbl
//
//  Created by Philipp Brendel on 02.04.22.
//

import Foundation
import Chalk

enum Hint: Equatable, Codable,
           CustomStringConvertible {
    case no
    case elsewhere([Position])
    case yes(Position)
    
    var description: String {
        switch self {
        case .no:
            return "no"
        case .elsewhere(let positions):
            return "elsewhere(\(positions.map{String(describing:$0)}.joined(separator: ", "))"
        case .yes(let position):
            return "yes(\(position))"
        }
    }
    
    var userString: String {
        switch self {
        case .no:
            return "#"
        case .yes:
            return "!"
        case .elsewhere:
            return "?"
        }
    }
    
    var color: Chalk.Color {
        switch self {
        case .no:
            return .extended(242)
        case .yes:
            return .green
        case .elsewhere:
            return .yellow
        }
    }
    
    var cost: Int {
        switch self {
        case .no:
            return 0
        case .yes:
            return 5
        case .elsewhere(let positions):
            return positions.count
        }
    }
}
