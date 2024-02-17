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
        }
        List(viewModel.players) {
            Text($0.name + " - Média: \($0.avarageScore)")
        }
    }
    
}

#Preview {
    PlayersHistoryView(viewModel: QuizViewModel())
}
