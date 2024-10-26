import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
// MARK: - Properties
    private let questionsAmount: Int = 10
        private var questionFactory: QuestionFactoryProtocol?
        private var currentQuestion: QuizQuestion?
        private var currentQuestionIndex = 0
        private var correctAnswers = 0
        private var alertPresenter: AlertPresenter?
        private var statisticService: StatisticServiceProtocol?
        
// MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = !currentQuestion.correctAnswer
        showAnswerResult(isCorrect: isCorrect)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: isCorrect)
    }
    
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    
// MARK: - Lifecycle
    override func viewDidLoad() {
            super.viewDidLoad()

            statisticService = StatisticService()
            
            // Инициализация фабрики вопросов и презентера алертов
            let questionFactory = QuestionFactory()
            questionFactory.setup(delegate: self)
            self.questionFactory = questionFactory

            alertPresenter = AlertPresenter(controller: self)

            // Настройка интерфейса
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 20
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.clear.cgColor

            showNextQuestion()  // Показ первого вопроса при загрузке
        }

// MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quizStep: viewModel)
        }
    }

    
// MARK: - Private Methods
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(named: model.image) ?? UIImage(named: "Картинка заглушка") ?? UIImage()
        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: formatQuestionNumber()
        )
    }
        
    private func formatQuestionNumber() -> String {
        return "\(currentQuestionIndex + 1)/\(questionsAmount)"
    }
        
    private func show(quizStep: QuizStepViewModel) {
        imageView.image = quizStep.image
        textLabel.text = quizStep.question
        counterLabel.text = quizStep.questionNumber
    }
        
    private func showFinalResults() {
        // Сохраняем текущие результаты
        statisticService?.store(correct: correctAnswers, total: questionsAmount)

        // Получаем данные из StatisticService
        guard let statisticService = statisticService else { return }
        
        let currentResult = "\(correctAnswers)/\(questionsAmount)"
        let totalGamesPlayed = statisticService.gamesCount
        let bestGame = statisticService.bestGame
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let formattedBestGameDate = dateFormatter.string(from: bestGame.date)
        let averageAccuracy = statisticService.totalAccuracy

        // Формируем текст для алерта
        let alertMessage = """
            Ваш результат: \(currentResult)
            Количество квизов: \(totalGamesPlayed)
            Лучший результат: \(bestGame.correct)/\(bestGame.total) (\(formattedBestGameDate))
            Средняя точность: \(String(format: "%.2f", averageAccuracy))%
        """
        let alertModel = AlertModel(
            title: "Финал",
            message: alertMessage,
            buttonText: "Попробовать снова",
            completion: { [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.showNextQuestion()
            }
        )
        
        alertPresenter?.showAlert(with: alertModel)
    }

        
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
            
        let ypGreen = UIColor(red: 0x60/255.0, green: 0xC2/255.0, blue: 0x8E/255.0, alpha: 1.0)
        let ypRed = UIColor(red: 0xF5/255.0, green: 0x6B/255.0, blue: 0x6C/255.0, alpha: 1.0)
            
        imageView.layer.borderColor = isCorrect ? ypGreen.cgColor : ypRed.cgColor
        changeStateButton(isEnable: false)
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.changeStateButton(isEnable: true)
            self.showNextQuestionOrResults()
        }
    }
        
    private func showNextQuestionOrResults() {
        if currentQuestionIndex >= questionsAmount - 1 {
            showFinalResults()
        } else {
            currentQuestionIndex += 1
            showNextQuestion()
        }
    }
        
    private func showNextQuestion() {
        imageView.layer.borderColor = UIColor.clear.cgColor
        questionFactory?.requestNextQuestion()
    }
        
    private func changeStateButton(isEnable: Bool) {
        noButton.isEnabled = isEnable
        yesButton.isEnabled = isEnable
    }
}


/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
