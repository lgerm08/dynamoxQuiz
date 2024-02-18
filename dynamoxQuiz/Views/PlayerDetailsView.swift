//
//  PlayerDetailsView.swift
//  dynamoxQuiz
//
//  Created by GIRA on 17/02/24.
//

import SwiftUI

struct PlayerDetailsView: View {
    
    @State var player: PlayerDb
    
    var body: some View {
        VStack(alignment: .center, spacing: 7) {
            Form {
                Section {
                    Text(player.name)
                }
                Section {
                    Text("Última pontuação: \(player.lastScore)")
                    Text("Quizzes realizados: \(player.quizzesTaken)")
                    Text("Média: \(player.avarageScore, specifier: "%.2f")")
                }
            }
        }
    }
}

#Preview {
    PlayerDetailsView(player: PlayerDb(name: "Teste", firstScore: 10.0))
}
