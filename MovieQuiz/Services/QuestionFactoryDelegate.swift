//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Мурад Манапов on 31.12.2022.
//

import Foundation


protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}
