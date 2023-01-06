//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Мурад Манапов on 05.01.2023.
//

import Foundation


protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}

final class StatisticServiceImplementation: StatisticService {
}
