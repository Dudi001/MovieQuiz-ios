import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertProtocolDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet private var mainView: UIView!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    private var questionFactory: QuestionFactoryProtocol? = nil
    private var alertPresenter: AlertPresenter?
    private let presenter = MovieQuizPresenter()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.alpha = 0.5
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
        alertPresenter = AlertPresenter(delegate: self)
        presenter.viewController = self
    }

    //MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        mainView.alpha = 1
        activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        activityIndicator.stopAnimating()
        showNetworkError(message: error.localizedDescription)
    }
    
    
    
    
    // MARK: - Private functions
    private func showLoadingIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .gray
        activityIndicator.startAnimating()
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            presenter.isCorrect()
            
            buttonToggle()
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrect ? UIColor(named: "YPGreen")?.cgColor : UIColor(named: "YPGreen")?.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
                self?.buttonToggle()
                guard let  self = self else { return }
                self.presenter.questionFactory = self.questionFactory
                self.presenter.showNextQuestionOrResults()
            }
        } else {
            buttonToggle()
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrect ? UIColor(named: "YPRed")?.cgColor : UIColor(named: "YPRed")?.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
                self?.buttonToggle()
                guard let  self = self else { return }
                self.presenter.showNextQuestionOrResults()
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

    
    
    private func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
                self.activityIndicator.startAnimating()
                self.questionFactory?.loadData()
            })
        
        alertPresenter?.showAlert(model: model)
    }
    
    
    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: {
                [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
                self.questionFactory?.requestNextQuestion()
            })
        
        alertPresenter?.showAlert(model: alertModel)
    }
    
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}


