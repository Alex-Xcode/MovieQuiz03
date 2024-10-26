import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func hideImageBorder()
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func showAlert(model: AlertModel)
    func setButtonsEnabled(_ isEnabled: Bool)
}

