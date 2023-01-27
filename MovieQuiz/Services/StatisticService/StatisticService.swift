//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Мурад Манапов on 05.01.2023.
//

import Foundation



final class StatisticServiceImplementation: StatisticService {
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    private let userDefaults = UserDefaults.standard
    
    
    var totalAccuracy: Double {
        get {
            userDefaults.double(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
            
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
            
        }
    }
    
    
    func store(correct count: Int, total amount: Int) {
        let newGame = GameRecord(correct: count, total: amount, date: Date())
        
        if newGame > bestGame {
            bestGame = newGame
        }
        
        if gamesCount != 0 {
            totalAccuracy = (totalAccuracy + (Double(newGame.correct) / Double(newGame.total))) / 2.0
        } else {
            totalAccuracy = (Double(newGame.correct) / Double(newGame.total))
        }
        gamesCount += 1
    }
}
