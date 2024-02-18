//
//  ContentView.swift
//  dynamoxQuiz
//
//  Created by GIRA on 15/02/24.
//

import SwiftUI
import RealmSwift

protocol PlayerHistoryProtocol {
    func updatePlayersList(palyer: PlayerDb)
}

struct HomeView: View, HomeProtocol {
    @State private var viewModel = QuizViewModel()
    @State private var name = ""
    @State private var quizStarted = false
    @State private var player: PlayerDb?
    
    
    var body: some View {
        NavigationView {
            if !quizStarted {
                Form {
                    Section {
                        VStack(alignment: .leading, spacing: 9) {
                            Text("Novo(a) Jogador(a):")
                            TextField("Nome ou Apelido", text: $name, onEditingChanged: { editingChanged in
                                if editingChanged {
                                    player = nil
                                }
                            })
                                .padding(5)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .border(.separator)
                        }
                    }
                    Section {
                        if !viewModel.players.isEmpty {
                            HStack(alignment: .center, spacing: 9) {
                                Picker("Já sou cadastrado:", selection: $player) {
                                    Text("Selecionar").tag(nil as PlayerDb?)
                                    ForEach(viewModel.players) { player in
                                        Text(player.name).tag(player as PlayerDb?)
                                    }
                                }
                                .onChange(of: player) {
                                    if player != nil {
                                        name = ""
                                    }
                                }
                            }
                        }
                    }
                    Section {
                        AsyncButton(action: {
                            self.registerPlayer()
                            await startQuiz()
                        }, label: {
                            Text("Iniciar Quiz")
                        })
                        .disabled(name.isEmpty && player == nil)
                    }
                    Section {
                            PlayersHistoryView(viewModel: viewModel)
                    }
                }
            } else {
                VStack(alignment: .center, spacing: 7) {
                    QuizView(viewModel: viewModel)
                    Button {
                        quizStarted = false
                        viewModel = QuizViewModel()
                    } label: {
                        Text("Desistir")
                    }
                }
            }
        }
        
        
    }
    
    private func registerPlayer() {
        if let oldPlayer = player {
            viewModel.player = oldPlayer
        } else {
            viewModel.saveNewPlayer(name: name)
        }
    }
    
    private func startQuiz() async {
        do {
            try await viewModel.getQuestions()
            self.viewModel.delegate = self
            self.quizStarted = true
            
        } catch {
            print(error)
        }
    }
    
    func finishQuiz() {
        quizStarted = false
        name = ""
        player = nil
        viewModel = QuizViewModel()
    }
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    HomeView()
}
