//
//  Question.swift
//  dynamoxQuiz
//
//  Created by GIRA on 15/02/24.
//

import Foundation

struct Question: Codable {
    let id: String
    let statement: String
    let options: [String]
}
