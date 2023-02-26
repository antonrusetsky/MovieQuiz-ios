//
//  AlertPresenter.swift
//  MovieQuiz
//
//

import UIKit

final class AlertPresenter {
    func alertMake (view controller: UIViewController, alert model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default, handler: { _ in model.completion()})
        
        alert.addAction(action)
        
        controller.present(alert, animated: true, completion: nil)
        
        model.completion()
    }
}
