//
//  QuizView.swift
//  dynamoxQuiz
//
//  Created by GIRA on 15/02/24.
//

import SwiftUI

struct QuizView: View {
    
    
    private var maxIndex: Int
    
    @ObservedObject private var viewModel: QuizViewModel
    @State private var selectedAnswer: String?
    @State var rightAnswers: Int = 0
    
    
    init(viewModel: QuizViewModel) {
        self.viewModel = viewModel
        self.maxIndex = viewModel.questions.count - 1
        
        self.viewModel.loadQuestion(shouldUpdateIndex: false)
    }
    
    var body: some View {
        if !viewModel.showResult {
            Form {
                Section {
                    Text("Pergunta \(viewModel.questionIndex + 1) de 10")
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
                                .foregroundStyle(selectedAnswer == option ? .blue : .black)
                        }
                    }
                }
                Section {
                    VStack(alignment: .center, spacing: 7) {
                        Button {
                            checkAnswer()
                        } label: {
                            Text("Checar Resposta")
                        }
                        .disabled(selectedAnswer == nil)
                    }
                }
            }
        } else {
            Form {
                Section {
                    Text("Jogador(a): \(viewModel.player?.name ?? "Indefinido")")
                }
                Section {
                    Text("Pontuação: \(rightAnswers)/10")
                    Text("Vocé jogou \(viewModel.player?.quizzesTaken ?? 0) vezes, e tem uma média de acertos de \(viewModel.player?.avarageScore ?? 0).")
                }
                Section {
                    AsyncButton(action: {
                        await restartQuiz()
                        viewModel.showResult = false
                        rightAnswers = 0
                        viewModel.restartQuiz()
                    }, label: {
                        Text("Iniciar Quiz")
                    })
                    Button(action: {
                        viewModel.finishQuiz()
                    }, label: {
                        Text("Voltar a tela princiapl")
                    })
                }
            }
        }
    }
    
    func checkAnswer() {
        if let answer = selectedAnswer {
                viewModel.checkAnswer(answer: answer) { result in
                    switch result {
                    case .success(let correction):
                        if correction.result {
                            self.rightAnswers += 1
                            self.viewModel.loadQuestion(rightAnswers: Float(self.rightAnswers))
                        } else {
                            self.viewModel.loadQuestion(rightAnswers: Float(self.rightAnswers))
                        }
                    case .failure(let failure):
                        print(failure)
                    }
                }
        }
        selectedAnswer = nil
    }
    
    private func restartQuiz() async {
        do {
            try await viewModel.getQuestions()
            
        } catch {
            print(error)
        }
    }
    
    
    
}

#Preview {
    QuizView(viewModel: QuizViewModel())
}
