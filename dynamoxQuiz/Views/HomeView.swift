//
//  ContentView.swift
//  dynamoxQuiz
//
//  Created by GIRA on 15/02/24.
//

import SwiftUI
import CoreData

struct HomeView: View, HomeProtocol {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Player.creationDate, ascending: true)],
        animation: .default)
    private var previousPlayers: FetchedResults<Player>
    @State private var viewModel = QuizViewModel()
    @State private var name = ""
    @State private var quizStarted = false
    
    var body: some View {
        if !quizStarted {
            VStack(alignment: .center, spacing: 7) {
                Text("Quem está jogando?")
                TextField("Nome ou apelido", text: $name)
                    .padding(5)
                    .disableAutocorrection(true)
                    .border(.secondary)
                AsyncButton(action: {
                    await startQuiz()
                }, label: {
                    Text("Iniciar Quiz")
                })
                .disabled(name.isEmpty)
        }
            .padding(15)
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
        viewModel = QuizViewModel()
    }
    

//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
//                    } label: {
//                        Text(item.timestamp!, formatter: itemFormatter)
// 

    private func addPlayer() {
        withAnimation {
            let newPlayer = Player(context: viewContext)
            newPlayer.name = viewModel.player
            newPlayer.creationDate = Date()
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { previousPlayers[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
