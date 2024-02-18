//
//  QuizView.swift
//  dynamoxQuiz
//
//  Created by GIRA on 15/02/24.
//

import SwiftUI

struct QuizView: View {
    
    // MARK: - Properties
    @ObservedObject private var viewModel: QuizViewModel
    @State private var selectedAnswer: String?
    @State var rightAnswers: Int = 0
    @State var errorMessage = ""
    @State var showingAlert = false
    
    // MARK: - Init Method
    init(viewModel: QuizViewModel) {
        self.viewModel = viewModel
        self.viewModel.loadQuestion(shouldUpdateIndex: false)
    }
    
    // MARK: - View Rendering
    var body: some View {
        if !viewModel.showResult {
            // MARK: - Questions view
            Form {
                Section {
                    Text("Pergunta \(viewModel.questionIndex + 1) de 10")
                        .bold()
                }
                Section {
                    Text("\(viewModel.currentQuestion)")
                }
                Section {
                    List(viewModel.currentOptions, id: \.self) { option in
                        Button {
                            selectedAnswer = option
                        } label: {
                            Text(option)
                                .bold(selectedAnswer == option)
                                .foregroundStyle(selectedAnswer == nil ? .black : viewModel.getTextColor(option: option, selectedAnswer: selectedAnswer ?? ""))
                        }
                        .disabled(!viewModel.isAllowedToAnswer)
                    }
                }
                Section {
                    VStack(alignment: .center, spacing: 7) {
                        AsyncButton {
                            checkAnswer()
                        } label: {
                            Text("Checar Resposta")
                        }
                        .disabled(selectedAnswer == nil || !viewModel.isAllowedToAnswer)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        } else {
            // MARK: - Results View
            Form {
                Section {
                    Text("Jogador(a): \(viewModel.player?.name ?? "Indefinido")")
                        .bold()
                }
                Section {
                    Text("Pontuação: \(rightAnswers)/10")
                    Text("Vocé jogou \(viewModel.player?.quizzesTaken ?? 0) vezes, e tem uma média de acertos de \(viewModel.player?.avarageScore ?? 0, specifier: "%.2f").")
                }
                Section {
                    AsyncButton(action: {
                        await restartQuiz()
                    }, label: {
                        Text("Iniciar Quiz Novamente")
                    })
                    .frame(maxWidth: .infinity)
                    .alert(errorMessage, isPresented: $showingAlert) {
                                Button("OK", role: .cancel) { }
                            }
                    Button(action: {
                        viewModel.finishQuiz()
                    }, label: {
                        Text("Voltar a tela principal")
                    })
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    // MARK: - Methods
    
    func checkAnswer() {
        if let answer = selectedAnswer {
            viewModel.checkAnswer(answer: answer) { result in
                switch result {
                case .success(let correction):
                    if correction.result {
                        self.rightAnswers += 1
                    }
                    self.giveFeedback()
                case .failure(let failure):
                    self.errorMessage = failure.localizedDescription
                    self.showingAlert = true
                }
            }
        }
    }
    
    private func giveFeedback() {
        DispatchQueue.main.async {
            self.viewModel.objectWillChange.send()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.selectedAnswer = nil
            self.viewModel.loadQuestion(rightAnswers: Float(self.rightAnswers))
        }
    }
    
    private func restartQuiz() async {
        do {
            try await viewModel.getQuestions()
            viewModel.showResult = false
            rightAnswers = 0
            viewModel.restartQuiz()
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.showingAlert = true
        }
    }
}

// MARK: - Preview
#Preview {
    QuizView(viewModel: QuizViewModel())
}
