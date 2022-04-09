//
//  Game.swift
//  Wharrgarbl
//
//  Created by Philipp Brendel on 02.04.22.
//

import Foundation
import Chalk

typealias Position = Int
typealias Letter = String

let wordLength = 5

//"/Users/waldrumpus/Downloads/code/Wharrgarbl/Wharrgarbl/words.txt"
func runWharrgarbl(wordsFile: String, cheatMode: Bool) {
    let words = try! String(contentsOfFile: wordsFile).split(separator: "\n").map {String($0)}
    var state = State()
    var lastWord = "undefined"

    print("This is a game similar to Wordle.\nGuess a 5 letter English word.\nThe word won't contain any duplicate letters.\nLetters that are not in the word will appear \("gray", color: .extended(242)), letters that occur in a different position will appear \("yellow", color: .yellow), and letters that occur in the position you've guessed will appear \("green", color: .green).\nYour guess:")

    while let guess = readLine()?.uppercased() {
        guard guess != "QUIT" else {
            print("\nThe word was \(lastWord)!")
            break
        }
        
        guard guess != "CHET" else {
            print("Last word: \(lastWord)")
            continue
        }
        
        guard valid(guess) else {
            print("Please enter a five letter word with no duplicate letters")
            continue;
        }
        
        guard words.contains(guess) else {
            print("Not in word list; please choose a different word")
            continue
        }
        
        if let searchResult = state.chooseWord(matching: guess, from: words) {
            
            guard searchResult.word != guess else {
                print("Congratulations! You found the word.")
                break
            }
            
            if cheatMode || CommandLine.arguments.contains(where: {$0.uppercased() == "CHEAT"}) {
                print("... psst... the secret word is \(searchResult.word)... don't tell anyone!")
            }
            
            lastWord = searchResult.word
            showHints(relevant(searchResult.hints, for: guess), for: guess)
        } else {
            print("couldn't find a word for you")
        }
        
        print("\nYour guess (enter QUIT to give up):")
    }


}

func relevant(_ hints: [Letter: Hint], for guess: String) -> [Letter: Hint] {
    var relevant: [Letter: Hint] = [:]
    
    for letter in guess.explode() {
        relevant[letter] = hints[letter]
    }
    
    return relevant
}

func showHints(_ hints: [Letter: Hint], for guess: String) {
    for letter in guess.explode() {
        let color = hints[letter]?.color ?? .red
        
        print("\(letter, color: color)", terminator: "")
    }
    print()
}

func valid(_ guess: String) -> Bool {
    guard guess.count == 5 else { return false }
    
    let letterCounts = Dictionary(grouping: guess, by: {$0})
    
    guard letterCounts.values.allSatisfy({$0.count == 1}) else {
        return false
    }
    
    return true
}
