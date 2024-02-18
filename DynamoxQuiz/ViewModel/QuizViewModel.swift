//
//  QuizViewModel.swift
//  dynamoxQuiz
//
//  Created by GIRA on 15/02/24.
//
import Foundation
import SwiftUI

// MARK: - HomeProtocol
protocol HomeProtocol {
    func finishQuiz()
    func cleanPlayerIfDeleted(playerdId: String)
}

class QuizViewModel: ObservableObject {
    
    // MARK: - Properties
    var player: Player?
    var questions = [Question]()
    var delegate: HomeProtocol?
    var playersManager = PlayersDbManager()
    var isAnswerRight: Bool?
    
    @Published var quizIsHappening = false
    @Published var currentQuestion = ""
    @Published var currentOptions = [String]()
    @Published var questionIndex = 0
    @Published var players = [Player]()
    @Published var showResult = false
    @Published var isAllowedToAnswer = true
    
    // MARK: - Init Method
    init() {
        self.reloadPlayersList()
    }
    
    // MARK: - View Management
    func restartQuiz() {
        questionIndex = 0
        loadQuestion(shouldUpdateIndex: false, rightAnswers: 0.0)
    }
    
    func loadQuestion(shouldUpdateIndex: Bool = true, rightAnswers: Float = 0.0) {
        isAnswerRight = nil
        DispatchQueue.main.async { [self] in
            questionIndex += shouldUpdateIndex ? 1 : 0
            if questions.indices.contains(questionIndex) {
                currentQuestion = questions[questionIndex].statement
                currentOptions = questions[questionIndex].options
                objectWillChange.send()
            } else {
                if let unwrappedPlayer = player {
                    playersManager.updatePlayerHistory(id: unwrappedPlayer.id, score: rightAnswers)
                    reloadPlayersList()
                    player = players.first(where: {$0.id == unwrappedPlayer.id})
                    showResult = true
                }
            }
            isAllowedToAnswer = true
        }
    }
    
    func getTextColor(option: String, selectedAnswer: String ) -> Color {
        if option == selectedAnswer && isAnswerRight == true {
            return .green
        } else if option == selectedAnswer && isAnswerRight == false {
            return .red
        } else if option == selectedAnswer && isAnswerRight == nil {
            return .blue
        }
        return .black
    }
    
    func finishQuiz() {
        delegate?.finishQuiz()
    }
    
}

// MARK: - Realm Manipulation
extension QuizViewModel {
    
    func reloadPlayersList() {
        players.removeAll()
        for playerData in Array(playersManager.getAllPlayers()) {
            players.append(Player(playerDB: playerData))
        }
    }
    
    func saveNewPlayer(name: String) {
        let playerDb = PlayerDb(name: name, firstScore: 0.0)
        playersManager.addPlayer(player: playerDb)
        reloadPlayersList()
        player = players.first(where: {$0.id == playerDb.id})
    }
}

// MARK: - Services Call
extension QuizViewModel {
    
    func getQuestions() async throws {
        questions.removeAll()
        
        guard let url = URL(string: "https://quiz-api-bwi5hjqyaq-uc.a.run.app/question") else {
            throw ConnectionErrors.badURL("Erro ao acessar servidos")
        }
        
        do {
            while questions.count < 10 {
                let (data, _) = try await URLSession.shared.data(from: url)
                let question = try JSONDecoder().decode(Question.self, from: data)
                if !questions.contains(where: {$0.id == question.id}) {
                    questions.append(question)
                }
            }
        } catch {
            throw error
        }
    }
    
    func checkAnswer(answer: String, completion: @escaping (Result<Correction, Error>) -> Void) {
        isAllowedToAnswer = false
        
        let id = questions[questionIndex].id
        let url = URL(string: "https://quiz-api-bwi5hjqyaq-uc.a.run.app/answer?questionId=" + id)
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let body = try? JSONEncoder().encode(["answer":answer])
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                completion(.failure(error))
            }
            
            if let correction = data {
                do {
                    let cleanJSONData = String(decoding: correction, as: UTF8.self)
                    print(cleanJSONData)
                    let result = try JSONDecoder().decode(Correction.self, from: correction)
                    self.isAnswerRight = result.result
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
