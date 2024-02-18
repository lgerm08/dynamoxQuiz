//
//  ContentView.swift
//  dynamoxQuiz
//
//  Created by GIRA on 15/02/24.
//

import SwiftUI
import RealmSwift

struct HomeView: View {
    
    // MARK: - Properties
    @State private var viewModel = QuizViewModel()
    @State private var name = ""
    @State private var quizStarted = false
    @State private var player: Player?
    @State var errorMessage = ""
    @State var showingAlert = false
    
    // MARK: - View Rendering
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
                                    Text("Selecionar").tag(nil as Player?)
                                    ForEach(viewModel.players, id: \.self) { player in
                                        Text(player.name).tag(player as Player?)
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
                        .frame(maxWidth: .infinity)
                        .alert(errorMessage, isPresented: $showingAlert) {
                                    Button("OK", role: .cancel) { showingAlert = false }
                                }
                    }
                    Section {
                            PlayersHistoryView(viewModel: viewModel, delegate: self)
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
        .padding(.vertical, 1)
    }
    
    // MARK: - Methods
    
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
            errorMessage = error.localizedDescription
            showingAlert = true
        }
    }
    
}

// MARK: - HomeProtocol

extension HomeView: HomeProtocol {
    
    func finishQuiz() {
        quizStarted = false
        name = ""
        player = nil
        viewModel = QuizViewModel()
    }
    
    func cleanPlayerIfDeleted(playerdId: String) {
        if playerdId == player?.id {
            player = nil
            viewModel.reloadPlayersList()
        }
    }
}

// MARK: - PlayerHistoryProtocol
extension HomeView: PlayerHistoryViewProtocol {
    func reloadList() {
        viewModel.reloadPlayersList()
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
