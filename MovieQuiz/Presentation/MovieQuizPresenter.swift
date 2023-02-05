//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Мурад Манапов on 05.02.2023.
//

import UIKit

final class MovieQuizPresenter {
    private var currentQuestionIndex: Int = 0
    let questionAmount: Int = 10
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1 
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
    }
}
