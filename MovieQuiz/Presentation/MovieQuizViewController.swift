import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter()
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion(by: currentQuestionIndex)
        statisticService = StatisticServiceImplementation()

    }
    // MARK: - QuestionFactoryDelegate

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
    

    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        let myButton = sender as UIButton
        myButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000))
        {
            myButton.isEnabled = true
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        let myButton = sender as UIButton
        myButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000))
        {
            myButton.isEnabled = true
        }
    }
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
//    private func show(quiz result: QuizResultsViewModel) {
//        let alertPresenter = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText, completion: { [weak self] in
//            guard let self = self else { return }
//            self.currentQuestionIndex = 0
//            self.correctAnswers = 0
//            self.questionFactory?.requestNextQuestion(by: self.currentQuestionIndex)
//        })
//
//        let alert = AlertPresenter()
//        alert.alertMake(view: self, alert: alertPresenter)
//        }
    
        func convert(model: QuizQuestion) -> QuizStepViewModel {
            QuizStepViewModel(
                image: UIImage(named: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        }
        
        func show(quiz step: QuizStepViewModel) {
            imageView.image = step.image
            textLabel.text = step.question
            counterLabel.text = step.questionNumber
        }
        
//    func showNextQuestionOrResults() {
//        if currentQuestionIndex == questionsAmount - 1 {
//            let text = correctAnswers == questionsAmount ?
//            "Поздравляем, Вы ответили на 10 из 10!" :
//            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
//
//            let viewModel = QuizResultsViewModel(
//                title: "Этот раунд окончен!",
//                text: text,
//                buttonText: "Сыграть ещё раз")
//            show(quiz: viewModel)
//        } else {
//            currentQuestionIndex += 1
//
//            questionFactory?.requestNextQuestion(by: currentQuestionIndex)
//        }
//    }
        
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            imageView.layer.borderWidth = 0
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            guard let gamesCount = statisticService?.gamesCount else { return }
            guard let totalAccuracy = statisticService?.totalAccuracy else { return }
            guard let bestGame = statisticService?.bestGame else { return }
            
            let alertModel = AlertModel(title: "Этот раунд окончен!",
                                                    message: """
Ваш результат: \(correctAnswers)/\(questionsAmount)
Количество сыгранных квизов: \(gamesCount)
Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
Средняя точность: \(String(format: "%.2f", totalAccuracy))%
""" ,
                                                    buttonText: "Сыграть еще раз",
                                                    completion: { [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion(by: self.currentQuestionIndex)})
                                                    
            alertPresenter?.alertMake(view: self, alert: alertModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion(by: currentQuestionIndex)
        }
    }
    
        func showAnswerResult(isCorrect: Bool) {
            if isCorrect {
                correctAnswers += 1
            }
            
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.imageView.layer.borderColor = UIColor.ypBlack.cgColor
                self.showNextQuestionOrResults()
            }
        }
    }
    

