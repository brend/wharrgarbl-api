import Vapor

struct WhaRequest: Codable, Content {
    let guess: String
    let state: State?
    let lang: Language?
}

struct WhaResponse: Codable, Content {
    let hiddenWord: String
    let state: State
    let error: String?
    let lang: Language?
}

struct WhaError: Error {
    let message: String
}

typealias Language = String

let defaultLanguage = "en"

var langWords: [Language: [String]] = [:]

func loadWordLists(from resourceDirectory: String) {
    let path = URL(fileURLWithPath: resourceDirectory)
    
    for lang in ["en", "de"] {
        let langPath = path.appendingPathComponent("words_\(lang).txt").path
        
        langWords[lang] = try? String(contentsOfFile: langPath).split(separator: "\n").map {String($0)}
    }
}

func routes(_ app: Application) throws {
    
    loadWordLists(from: app.directory.resourcesDirectory)
    
    app.post { req -> WhaResponse in
        let request = try req.content.decode(WhaRequest.self)
        let options = GameOptions(randomize: true)
        let lang = request.lang ?? defaultLanguage
        let words = langWords[lang]!
        
        // guess must be in word list
        guard words.contains(request.guess) else {
            return WhaResponse(hiddenWord: "ABCDE", state: State(), error: "I don't know that word, please choose another", lang: nil)
        }
        
        var state = request.state ?? State()
        
        guard let result = state.chooseWord(matching: request.guess,
                                            from: words,
                                            options: options)
        else {
            throw WhaError(message: "could not find a word")
        }
        
        let response = WhaResponse(hiddenWord: result.word, state: state, error: nil, lang: lang)
        
        return response
    }
}
