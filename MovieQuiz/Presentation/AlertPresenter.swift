//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Мурад Манапов on 01.01.2023.
//

import UIKit

class AlertPresenter: AlertProtocol{
    private weak var delegate: AlertProtocolDelegate?
    
    
    init(delegate: AlertProtocolDelegate) {
        self.delegate = delegate
    }
    
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Game result"
        
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default) {_ in
                model.completion()
            }
        
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    } 
}
