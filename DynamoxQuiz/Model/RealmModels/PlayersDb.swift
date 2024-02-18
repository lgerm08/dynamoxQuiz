//
//  PlayersDb.swift
//  dynamoxQuiz
//
//  Created by GIRA on 16/02/24.
//
import Foundation
import RealmSwift

final class PlayerDb: Object, ObjectKeyIdentifiable {
    @Persisted var id: String
    @Persisted var name: String
    @Persisted var quizzesTaken: Int = 0
    @Persisted var avarageScore: Float = 0.0
    @Persisted var lastQuizTaken: Date
    @Persisted var lastScore: Float = 0.0
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    convenience init (
        name: String,
        firstScore: Float
    ) {
        self.init()
        self.id = UUID().uuidString
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
            let sameNamePlayers = realm.objects(PlayerDb.self).filter(NSPredicate(format: "name == %@", player.name))
            if !sameNamePlayers.isEmpty {
                player.name += " (\(sameNamePlayers.count + 1))"
            }
            realm.add(player, update: .all)
        }
    }
    
    public func getAllPlayers() -> List<PlayerDb> {
        players.append(objectsIn: realm.objects(PlayerDb.self))
        return players
    }
    
    public func updatePlayerHistory(id: String, score: Float) {
        try! realm.write {
            let players = realm.objects(PlayerDb.self).filter(NSPredicate(format: "id == %@", id ))
            if let player = players.first {
                player.lastQuizTaken = Date()
                player.avarageScore = (player.avarageScore*Float(player.quizzesTaken) + score)/(Float(player.quizzesTaken) + 1.0)
                player.quizzesTaken += 1
                player.lastScore = score
            }
        }
    }
    
    func deletePlayerData(playerId: String) {
        try! realm.write {
            realm.delete(realm.objects(PlayerDb.self).filter(NSPredicate(format: "id == %@", playerId)))
        }
    }
    
    func deleteAllPlayers() {
        try! realm.write {
            realm.delete(realm.objects(PlayerDb.self))
        }
    }
}
