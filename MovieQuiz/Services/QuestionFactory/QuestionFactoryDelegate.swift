//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Мурад Манапов on 31.12.2022.
//

import Foundation


protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
