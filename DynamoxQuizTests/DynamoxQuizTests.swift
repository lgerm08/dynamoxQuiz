//
//  dynamoxQuizTests.swift
//  dynamoxQuizTests
//
//  Created by GIRA on 15/02/24.
//

import XCTest
import SwiftUI
@testable import DynamoxQuiz

final class DynamoxQuizTests: XCTestCase {
    
    func testIfPlayerReceivesValueAfterUserRegisters() {
          let viewModel = QuizViewModel()
          viewModel.saveNewPlayer(name: "Teste")
          
          XCTAssertNotNil(viewModel.player)
      }
    
    func testIfTextIsGreenIfRightAnswerIsSelected()  {
        var viewModel = QuizViewModel()
        viewModel.isAnswerRight = true
        
        let color = viewModel.getTextColor(option: "test option", selectedAnswer: "test option")
        
        XCTAssertEqual(color, Color.green)
    }
    
    func testIfTextIsRedIfWrongAnswerIsSelected()  {
        var viewModel = QuizViewModel()
        viewModel.isAnswerRight = false
        
        let color = viewModel.getTextColor(option: "test option", selectedAnswer: "test option")
        
        XCTAssertEqual(color, Color.red)
    }
    
    func testIfTextIsBlueIfOptionIsSelectedButWasNotChecked()  {
        var viewModel = QuizViewModel()
        viewModel.isAnswerRight = nil
        
        let color = viewModel.getTextColor(option: "test option", selectedAnswer: "test option")
        
        XCTAssertEqual(color, Color.blue)
    }
    
    func testIfTextIsBlackIfOptionIsNotSelected() {
        var viewModel = QuizViewModel()
        viewModel.isAnswerRight = nil
        
        let color = viewModel.getTextColor(option: "test option", selectedAnswer: "diferent option")
        
        XCTAssertEqual(color, Color.black)
    }

}
