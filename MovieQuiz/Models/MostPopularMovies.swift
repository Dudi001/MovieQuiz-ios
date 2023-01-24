//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Мурад Манапов on 22.01.2023.
//

import Foundation


struct MostPopularMovies: Codable {
    let errorMessage: String
    let item: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL =  "image"
    }
}


