//
//  Player.swift
//  dynamoxQuiz
//
//  Created by GIRA on 18/02/24.
//

import Foundation

struct Player: Identifiable, Equatable, Hashable {
    var id: String
    var name: String
    var quizzesTaken: Int = 0
    var avarageScore: Float = 0.0
    var lastQuizTaken: Date
    var lastScore: Float = 0.0
    
    init(
        playerDB: PlayerDb
    ){
        self.id = playerDB.id
        self.name = playerDB.name
        self.quizzesTaken = playerDB.quizzesTaken
        self.avarageScore = playerDB.avarageScore
        self.lastQuizTaken = playerDB.lastQuizTaken
        self.lastScore = playerDB.lastScore
    }
    
    static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
    
