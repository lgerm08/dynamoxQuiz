//
//  PlayerDetailsView.swift
//  dynamoxQuiz
//
//  Created by GIRA on 17/02/24.
//

import SwiftUI

struct PlayerDetailsView: View {
    
    @State var player: Player
    
    var body: some View {
        VStack(alignment: .center, spacing: 7) {
            Form {
                Section {
                    Text(player.name)
                }
                Section {
                    Text("Última pontuação: \(player.lastScore, specifier: "%.2f")")
                    Text("Quizzes realizados: \(player.quizzesTaken)")
                    Text("Média: \(player.avarageScore, specifier: "%.2f")")
                }
            }
        }
        .padding(.vertical, 1)
    }
}

#Preview {
    PlayerDetailsView(player: Player(playerDB: PlayerDb(name: "Teste", firstScore: 10.0)))
}
