//
//  State.swift
//  Wharrgarbl
//
//  Created by Philipp Brendel on 02.04.22.
//

import Foundation

struct GameOptions {
    let randomize: Bool
}

struct State: Codable {
    var hints: [Letter: Hint] = [:]
    
    func fits(_ word: String) -> Bool {
        let lettersOfWord = word.explode()
        
        for (letter, hint) in hints {
            switch hint {
            case .no:
                guard !lettersOfWord.contains(letter) else {
                    return false
                }
            case .yes(let position):
                guard lettersOfWord[position] == letter else {
                    return false
                }
            case .elsewhere(let positions):
                guard lettersOfWord.contains(letter)
                        && positions.allSatisfy({lettersOfWord[$0] != letter})
                else { return false }
            }
        }
        
        return true
    }
    
    mutating func pruneWords(words: [String]) -> [String] {
        words.filter { fits($0) }
    }
    
    func score(_ word: String, guess: String) -> Int {
        hintsFor(word, guess: guess).values.reduce(0, {$0 + $1.cost})
    }
    
    func hintsFor(_ word: String, guess: String) -> [Letter: Hint] {
        var newHints: [Letter: Hint] = [:]
        
        for (i, letter) in guess.explode().enumerated() {
            if word.contains(letter) {
                newHints[letter] = (word[i] == letter) ? .yes(i) : .elsewhere([i])
            } else {
                newHints[letter] = .no
            }
        }
        
        return newHints
    }
    
    mutating func integrate(_ newHints: [Letter: Hint]) {
        for (letter, hint) in newHints {
            switch hints[letter] {
            case nil:
                hints[letter] = hint
            case .no:
                guard hint == .no else { fatalError() }
            case .yes:
                guard hint == hints[letter] else { fatalError() }
            case .elsewhere(let positions):
                switch hint {
                case .yes:
                    hints[letter] = hint
                case .elsewhere(let newPositions):
                    var allPositions = positions
                    
                    allPositions.append(contentsOf: newPositions)
                    
                    hints[letter] = .elsewhere(Array(Set(allPositions)))
                default:
                    fatalError()
                }
            }
        }
    }
    
    mutating func chooseWord(
        matching guess: String,
        from words: [String],
        options: GameOptions) -> SearchResult?
    {
        var words = pruneWords(words: words)
        
        if options.randomize {
            words.shuffle()
        }
        
        let wordScores = Dictionary(grouping: words) {
            self.score($0, guess: guess)
        }

        if let minScore = wordScores.keys.min(),
           let word = wordScores[minScore]?.first
        {
            guard minScore != Int.max else {
                Swift.print("min score is infinite")
                return nil
            }
            
            let newHints = hintsFor(word, guess: guess)
            
            integrate(newHints)

            return SearchResult(word: word, score: minScore, hints: newHints)
        } else {
            return nil
        }
    }
    
    func print() {
        Swift.print(hints.sorted(by: {$0.key < $1.key}).map {"\($0.key): \($0.value)"}.joined(separator: ", "))
        //Swift.print(words.joined(separator: ", "))
    }
}
