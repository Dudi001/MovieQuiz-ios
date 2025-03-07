//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Мурад Манапов on 05.02.2023.
//
import UIKit


final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var task: DispatchWorkItem?
    private var statisticService: StatisticService?
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewCintrollerProtocol?
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    let questionAmount: Int = 10
    var currentQuestion: QuizQuestion?
    
    init(viewController: MovieQuizViewCintrollerProtocol) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        viewController?.mainView.alpha = 1
        viewController?.activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.activityIndicator.stopAnimating()
        viewController?.showNetworkError(message: message)
    }
    
    private func isCorrect() {
        correctAnswers += 1
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        self.questionFactory?.requestNextQuestion()
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
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            self.isCorrect()
            
            viewController?.buttonToggle()
            viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
                self?.viewController?.buttonToggle()
                guard let  self = self else { return }
                self.showNextQuestionOrResults()
            }
        } else {
            viewController?.buttonToggle()
            viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
                self?.viewController?.buttonToggle()
                guard let  self = self else { return }
                self.showNextQuestionOrResults()
            }
        }
    }
    
    //MARK: - Alert
    
    private func showNextQuestionOrResults() {
        statisticService = StatisticServiceImplementation()
        
        if self.isLastQuestion {
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
            viewController?.show(quiz: viewModel)
        } else {
            task = DispatchWorkItem { self.viewController?.activityIndicator.startAnimating() }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: (task!))
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
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
        self.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
