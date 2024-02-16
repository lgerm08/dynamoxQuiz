//
//  dynamoxQuizApp.swift
//  dynamoxQuiz
//
//  Created by GIRA on 15/02/24.
//

import SwiftUI

@main
struct dynamoxQuizApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
