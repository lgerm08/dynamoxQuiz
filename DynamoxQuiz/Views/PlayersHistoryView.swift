//
//  PlayersHistoryView.swift
//  dynamoxQuiz
//
//  Created by GIRA on 16/02/24.
//

import SwiftUI
import RealmSwift

protocol PlayerHistoryViewProtocol {
    func reloadList()
}

struct PlayersHistoryView: View {
    
    @State var viewModel: QuizViewModel
    
    var delegate: PlayerHistoryViewProtocol
    
    var body: some View {
        VStack(alignment: .center, spacing: 7) {
                Text("Histórico")
                    .frame(maxWidth: .infinity)
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
                .listRowSeparator(.hidden)
            }
        }
        
    }
}

