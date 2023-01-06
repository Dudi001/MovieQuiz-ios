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
    
    
    func countRecord() {
        
    }
}
