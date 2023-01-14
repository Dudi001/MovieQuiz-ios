//
//  AlertProtocolDelegate.swift
//  MovieQuiz
//
//  Created by Мурад Манапов on 02.01.2023.
//

import UIKit

protocol AlertProtocolDelegate: AnyObject {
    func present(_ viewControllerToPresent: UIViewController,
                 animated flag:Bool,
                 completion: (() ->Void)?)
}
    
