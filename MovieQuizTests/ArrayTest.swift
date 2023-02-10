//
//  ArrayTest.swift
//  MovieQuizTests
//
//  Created by Мурад Манапов on 28.01.2023.
//

import XCTest
@testable import MovieQuiz


class ArrayTest: XCTestCase {
    func testGetValueInRange() throws{
        let array = [0, 1, 2, 3, 4, 5]
        
        let indexArray = array[safe: 2]
        
        XCTAssertNotNil(indexArray)
        XCTAssertEqual(indexArray, 2)
    }
    
    func testValueOutInRange() throws {
        let array = [0, 1, 2, 3, 4, 5]
        
        let indexArray = array[safe: 7]
        
        XCTAssertNil(indexArray)
    }
}
