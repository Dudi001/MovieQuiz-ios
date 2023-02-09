//
//  MovieQuizPresenter.swift
//  MovieQuizTests
//
//  Created by Мурад Манапов on 08.02.2023.
//

import Foundation

import XCTest
@testable import MovieQuiz

final class MovieQuizControllerProtocolMock: MovieQuizViewCintrollerProtocol {
    var activityIndicator: UIActivityIndicatorView!
    
    var mainView: UIView!
    
    func buttonToggle() { }
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) { }

    func show(quiz result: MovieQuiz.QuizResultsViewModel) { }

    func highlightImageBorder(isCorrectAnswer: Bool) { }

    func showLoadingIndicator() { }

    func hideLoadingIndicator() { }

    func showNetworkError(message: String) { }

}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
    let viewControllerMock = MovieQuizControllerProtocolMock()
    let sut = MovieQuizPresenter(viewController: viewControllerMock)

    let emptyData = Data()
    let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
    let viewModel = sut.convert(model: question)

     XCTAssertNotNil(viewModel.image)
    XCTAssertEqual(viewModel.question, "Question Text")
    XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
