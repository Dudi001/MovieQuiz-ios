//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Мурад Манапов on 05.02.2023.
//

import UIKit

final class MovieQuizPresenter {
    private var task: DispatchWorkItem?
    private var statisticService: StatisticService?
    var questionFactory: QuestionFactoryProtocol? = nil
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    let questionAmount: Int = 10
    
    weak var viewController: MovieQuizViewController?
    var currentQuestion: QuizQuestion?
    
    
    
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
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        task?.cancel()
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.activityIndicator.stopAnimating()
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    //MARK: - Alert
    func showNextQuestionOrResults() {
        statisticService = StatisticServiceImplementation()
        
        if self.isLastQuestion() {
            guard let statisticService = statisticService else { return }
            self.statisticService?.store(correct: correctAnswers, total: self.questionAmount)
            let totalAccurancyPercentage = String(format: "%.2f", statisticService.totalAccuracy * 100) + "%"
            let localTime = statisticService.bestGame.date.dateTimeString
            let bestGameStart = "\(statisticService.bestGame.correct) / \(statisticService.bestGame.total)"
            
            let text = """
            Ваш результат: \(correctAnswers) из \(self.questionAmount)
            Колличество сыграных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGameStart) (\(localTime))
            Средняя точность: \(totalAccurancyPercentage)
        """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.imageView.layer.borderWidth = 0
            viewController?.show(quiz: viewModel)
        } else {
            task = DispatchWorkItem { self.viewController?.activityIndicator.startAnimating() }
            // ставим таск на 0.3 секунды для показа спиннера загрузки, только в случае медленного соединия
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: (task!))
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            self.viewController?.imageView.layer.borderWidth = 0
        }
    }
    
    
    //MARK: - Button_func
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
