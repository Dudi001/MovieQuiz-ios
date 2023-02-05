import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertProtocolDelegate {
    
    // MARK: - Lifecycle
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet private var mainView: UIView!
    
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol? = nil
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    private var task: DispatchWorkItem?
    private let presenter = MovieQuizPresenter()
    
    
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.alpha = 0.5
        imageView.layer.cornerRadius = 20
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    //MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
        mainView.alpha = 1
        activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        activityIndicator.stopAnimating()
        showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        task?.cancel()
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.show(quiz: viewModel)
        }
    }
    
    
    // MARK: - Private functions
    private func showLoadingIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .gray
        activityIndicator.startAnimating()
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
            
            buttonToggle()
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrect ? UIColor(named: "YPGreen")?.cgColor : UIColor(named: "YPGreen")?.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
                self?.buttonToggle()
                guard let  self = self else { return }
                self.showNextQuestionOrResults()
            }
        } else {
            buttonToggle()
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrect ? UIColor(named: "YPRed")?.cgColor : UIColor(named: "YPRed")?.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
                self?.buttonToggle()
                guard let  self = self else { return }
                self.showNextQuestionOrResults()
            }
        }
    }
    
    private func buttonToggle() {
        self.noButton.isEnabled.toggle()
        self.yesButton.isEnabled.toggle()
        self.yesButton.alpha = yesButton.isEnabled ? 1.0 : 0.5
        self.noButton.alpha = noButton.isEnabled ? 1.0 : 0.5
    }
    
    //MARK: - Alert
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion(){
            
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: presenter.questionAmount)
            let totalAccurancyPercentage = String(format: "%.2f", statisticService.totalAccuracy * 100) + "%"
            let localTime = statisticService.bestGame.date.dateTimeString
            let bestGameStart = "\(statisticService.bestGame.correct) / \(statisticService.bestGame.total)"
            
            let text = """
            Ваш результат: \(correctAnswers) из \(presenter.questionAmount)
            Колличество сыграных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGameStart) (\(localTime))
            Средняя точность: \(totalAccurancyPercentage)
        """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            imageView.layer.borderWidth = 0
            show(quiz: viewModel)
        } else {
            task = DispatchWorkItem { self.activityIndicator.startAnimating() }
            // ставим таск на 0.3 секунды для показа спиннера загрузки, только в случае медленного соединия
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: task!)
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            imageView.layer.borderWidth = 0
        }
    }
    
    
    private func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                self.activityIndicator.startAnimating()
                self.questionFactory?.loadData()
            })
        
        alertPresenter?.showAlert(model: model)
    }
    
    
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: {
                [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            })
        
        alertPresenter?.showAlert(model: alertModel)
    }
    
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}


