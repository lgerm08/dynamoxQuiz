//
//  PlayersHistoryView.swift
//  dynamoxQuiz
//
//  Created by GIRA on 16/02/24.
//

import SwiftUI
import RealmSwift



struct PlayersHistoryView: View {
    
    @State var viewModel: QuizViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 7) {
            Text("Histórico de Partidas")
                .multilineTextAlignment(.center)
        }
        List {
            ForEach(viewModel.players){ player in
                NavigationLink(destination: PlayerDetailsView(player: player)) {
                    HStack(alignment: .center) {
                        Text(player.name)
                            .frame(maxWidth: .infinity)
                        Text("Média: \(player.avarageScore, specifier: "%.2f")")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .onDelete(perform: { index in
                viewModel.deletePlayerHistory(playerIndex: index)
            })
            
        }
        
    }
}

#Preview {
    PlayersHistoryView(viewModel: QuizViewModel())
}
