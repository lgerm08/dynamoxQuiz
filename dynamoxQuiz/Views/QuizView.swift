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
    @State private var rightAnswers: Int = 0
    
    
    init(viewModel: QuizViewModel) {
        self.viewModel = viewModel
        self.maxIndex = viewModel.questions.count - 1
        
        self.viewModel.loadQuestion(shouldUpdateIndex: false)
    }
    
    var body: some View {
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
            Section {
                Text("Pontuação: \(rightAnswers)/10")
            }
        }
    }
    
    func checkAnswer() {
        if let answer = selectedAnswer {
                viewModel.postBattle(answer: answer) { result in
                    switch result {
                    case .success(let correction):
                        if correction.result {
                            self.rightAnswers += 1
                            self.viewModel.loadQuestion()
                        } else {
                            self.viewModel.loadQuestion()
                        }
                    case .failure(let failure):
                        print(failure)
                    }
                }
        }
        selectedAnswer = nil
    }
    
    
    
}

#Preview {
    QuizView(viewModel: QuizViewModel())
}
