//
//  QuizViewModel.swift
//  dynamoxQuiz
//
//  Created by GIRA on 15/02/24.
//
import Foundation
import SwiftUI

protocol HomeProtocol {
    func finishQuiz()
}

class QuizViewModel: ObservableObject {
    
    var player: PlayerDb?
    var questions = [Question]()
    var delegate: HomeProtocol?
    var playersManager = PlayersDbManager()
    
    @Published var quizIsHappening = false
    @Published var currentQuestion = ""
    @Published var currentOptions = [String]()
    @Published var questionIndex = 0
    @Published var players = [PlayerDb]()
    @Published var showResult = false
    
    init() {
        self.getPreviousPlayers()
    }
    
    func getQuestions() async throws {
        questions.removeAll()
        guard let url = URL(string: "https://quiz-api-bwi5hjqyaq-uc.a.run.app/question") else {
            return
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
            print(error)
        }
    }
    
    func checkAnswer(answer: String, completion: @escaping (Result<Correction, Error>) -> Void) {
        // Prepare URL
        let id = questions[questionIndex].id
        let url = URL(string: "https://quiz-api-bwi5hjqyaq-uc.a.run.app/answer?questionId=" + id)
        guard let requestUrl = url else { fatalError() }
        
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // HTTP Request Parameters which will be sent in HTTP Request Body
        
        let body = try? JSONEncoder().encode(["answer":answer])
        request.httpBody = body
        
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                completion(.failure(error))
            }
            
            // Convert HTTP Response Data to a String
            if let correction = data {
                do {
                    let cleanJSONData = String(decoding: correction, as: UTF8.self)
                    print(cleanJSONData)
                    let result = try JSONDecoder().decode(Correction.self, from: correction)
                    completion(.success(result))
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
        
    }
    
    func getPreviousPlayers() {
        players = Array(playersManager.getAllPlayers())
    }
    
    func saveNewPlayer(name: String) {
        player = PlayerDb(name: name, firstScore: 0.0)
        playersManager.addPlayer(player: player!)
        getPreviousPlayers()
    }
    
    func restartQuiz() {
        questionIndex = 0
        loadQuestion(shouldUpdateIndex: false, rightAnswers: 0.0)
    }
    
    func loadQuestion(shouldUpdateIndex: Bool = true, rightAnswers: Float = 0.0) {
        
        DispatchQueue.main.async { [self] in
            questionIndex += shouldUpdateIndex ? 1 : 0
            if questions.indices.contains(questionIndex) {
                currentQuestion = questions[questionIndex].statement
                currentOptions = questions[questionIndex].options
                objectWillChange.send()
            } else {
                if let player = player {
                    playersManager.updatePlayerHistory(name: player.name, score: rightAnswers)
                    showResult = true
                }
            }
        }
    }
    
    func finishQuiz() {
        delegate?.finishQuiz()
    }
    
    
}
