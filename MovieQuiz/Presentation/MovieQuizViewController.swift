import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertProtocolDelegate {
    
    // MARK: - Lifecycle
    
    
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    
    private var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0
    private let questionAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol? = nil
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
    
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    //MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    
    // MARK: - Private functions
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
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
            
            yesButton.isEnabled = false
            noButton.isEnabled = false
            
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            
            imageView.layer.borderColor = isCorrect ? UIColor(named: "YPGreen")?.cgColor : UIColor(named: "YPGreen")?.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
                guard let  self = self else { return }
                self.showNextQuestionOrResults()
            }
        } else {
            self.yesButton.isEnabled = false
            self.noButton.isEnabled = false
            
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.cornerRadius = 20
            imageView.layer.borderColor = isCorrect ? UIColor(named: "YPRed")?.cgColor : UIColor(named: "YPRed")?.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
                //добавляем слабую ссылку на self для удаления retail cycle
                guard let  self = self else { return }
                self.showNextQuestionOrResults()
            }
        }
    }
    
    //MARK: - Alert
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionAmount - 1 {
            
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: questionAmount)
            
            let totalAccurancyPercentage = String(format: "%.2f", statisticService.totalAccuracy * 100) + "%"
            
            let localTime = statisticService.bestGame.date.dateTimeString
            let bestGameStart = "\(statisticService.bestGame.correct) / \(statisticService.bestGame.total)"
            
            let text = """
            Ваш результат: \(correctAnswers) из \(questionAmount)
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
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            imageView.layer.borderWidth = 0
        }
    }
    
    
    
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: {
                [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                
                // скидываем счётчик правильных ответов
                self.correctAnswers = 0
                
                // заново показываем первый вопрос
                self.questionFactory?.requestNextQuestion()
            })
        
        alertPresenter?.showAlert(model: alertModel)
    }
    
    // MARK: - Actions
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}


