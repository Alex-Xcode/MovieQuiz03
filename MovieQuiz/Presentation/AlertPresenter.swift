//
//  AlertPresenter.swift
//  MovieQuiz
//

import Foundation
import UIKit

final class AlertPresenter {
    private weak var controller: UIViewController?

    init(controller: UIViewController) {
        self.controller = controller
    }

    func showAlert(with model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        alert.addAction(action)
        controller?.present(alert, animated: true, completion: nil)
    }
}
