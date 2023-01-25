//
//  GameRecordModel.swift
//  MovieQuiz
//
//  Created by Мурад Манапов on 06.01.2023.
//

import Foundation


struct GameRecord: Codable, Comparable {

    let correct: Int
    let total: Int
    let date: Date

    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        if lhs.total == 0 {
            return true
        }
        
        let lhsAll = Double(lhs.correct) / Double(lhs.total)
        let rhsAll = Double(rhs.correct) / Double(rhs.total)
        
        return lhsAll < rhsAll
    }
}
