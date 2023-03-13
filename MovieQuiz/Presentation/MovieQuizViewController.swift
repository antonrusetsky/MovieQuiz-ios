import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        activityIndicator.hidesWhenStopped = true
        alertPresenter = AlertPresenter()
        imageView.layer.cornerRadius = 20
        
        presenter.statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
    }
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    lazy var buttons: [UIButton] = [self.yesButton, self.noButton]
    @IBAction internal func yesButtonClicked(_ sender: UIButton) {
        for button in self.buttons {
            button.isEnabled = false
        }
        presenter.yesButtonClicked()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000))
        {
            for button in self.buttons {
                button.isEnabled = true
            }
        }
    }
    
    @IBAction internal func noButtonClicked(_ sender: UIButton) {
        for button in self.buttons {
            button.isEnabled = false
        }
        presenter.noButtonClicked()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000))
        {
            for button in self.buttons {
                button.isEnabled = true
            }
        }
    }
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderColor = UIColor.ypBlack.cgColor
        }
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            self.correctAnswers = 0
            
            self.presenter.restartGame()
        }
        
        alertPresenter?.alertMake(view: self, alert: model)
    }
}
