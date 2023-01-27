//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Мурад Манапов on 29.12.2022.
//

import Foundation

private enum QuestionError: String, Error {
    case errorLoadImage = "Ошибка при загрузке изображения"
    case errorRespons = "Ошибка загрузки данных"
}

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(_):
                    self.delegate?.didFailToLoadData(with: QuestionError.errorRespons)
                }
            }
        }
    }
    
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: QuestionError.errorLoadImage)
                    return
                }
            }
            
            let rating = Float(movie.rating) ?? 0
            let checkRating = Int.random(in: 7...9)
            let text = "Рейтинг этого фильма больше чем \(checkRating)?"
            let correctAnswer = rating > Float(checkRating)
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
