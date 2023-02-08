import UIKit


protocol MovieQuizViewCintrollerProtocol: AnyObject {
    var activityIndicator: UIActivityIndicatorView! { get set }
    var mainView: UIView! { get set }
    func show(quiz step:QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func buttonToggle()
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
}


final class MovieQuizViewController: UIViewController, AlertProtocolDelegate, MovieQuizViewCintrollerProtocol {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    private var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.alpha = 0.5
        imageView.layer.cornerRadius = 20
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
        alertPresenter = AlertPresenter(delegate: self)

    }
    
    
    // MARK: - Private functions
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor(named: "YPGreen")?.cgColor : UIColor(named: "YPRed")?.cgColor
        
    }
    
    func showLoadingIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .gray
        activityIndicator.startAnimating()
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    func buttonToggle() {
        self.noButton.isEnabled.toggle()
        self.yesButton.isEnabled.toggle()
        self.yesButton.alpha = yesButton.isEnabled ? 1.0 : 0.5
        self.noButton.alpha = noButton.isEnabled ? 1.0 : 0.5
    }
    
    
    //MARK: - Alert
    
    func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
                self.activityIndicator.startAnimating()
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


