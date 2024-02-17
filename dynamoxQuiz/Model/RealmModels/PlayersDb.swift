//
//  PlayersDb.swift
//  dynamoxQuiz
//
//  Created by GIRA on 16/02/24.
//
import Foundation
import RealmSwift

final class PlayerDb: Object, ObjectKeyIdentifiable {
    @Persisted var name: String
    @Persisted var quizzesTaken: Int = 0
    @Persisted var avarageScore: Float = 0.0
    @Persisted var lastQuizTaken: Date
    
    override class func primaryKey() -> String {
        return "name"
    }
    
    convenience init (
        name: String,
        firstScore: Float
    ) {
        self.init()
        self.name = name
        self.avarageScore = firstScore
        self.lastQuizTaken = Date()
    }
    
}

class PlayersDbManager {
    let realm = try! Realm()
    let players = List<PlayerDb>()
    
    public func addPlayer(player: PlayerDb) {
        try! realm.write {
            realm.add(player, update: .all)
        }
    }
    
    public func getAllPlayers() -> List<PlayerDb> {
        players.append(objectsIn: realm.objects(PlayerDb.self))
        return players
    }
    
    public func updatePlayerHistory(name: String, score: Float) {
        try! realm.write {
            let players = realm.objects(PlayerDb.self).filter(NSPredicate(format: "name == %@", name ))
            if let player = players.first {
                player.lastQuizTaken = Date()
                player.avarageScore = (player.avarageScore*Float(player.quizzesTaken) + score)/(Float(player.quizzesTaken) + 1.0)
                player.quizzesTaken += 1
            }
        }
    }
}
