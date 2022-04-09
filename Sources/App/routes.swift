import Vapor

struct WhaRequest: Codable, Content {
    let guess: String
    let state: State
}

struct WhaResponse: Codable, Content {
    let hiddenWord: String
    let state: State
}

struct WhaError: Error {
    let message: String
}

var words: [String] = []

func routes(_ app: Application) throws {
    
    let path = URL(fileURLWithPath: app.directory.resourcesDirectory).appendingPathComponent("words.txt").path
    
    words = try! String(contentsOfFile: path).split(separator: "\n").map {String($0)}
    
    print(app.directory.resourcesDirectory)
    
    app.post { req -> WhaResponse in
        let request = try req.content.decode(WhaRequest.self)
        var state = request.state
        guard let result = state.chooseWord(matching: request.guess, from: words) else {
            throw WhaError(message: "could not find a word")
        }
        let response = WhaResponse(hiddenWord: result.word, state: state)

        return response
    }
}
