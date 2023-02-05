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
        //Given
        let array = [0, 1, 2, 3, 4, 5]
        
        //When
        let indexArray = array[safe: 2]
        
        //Then
        XCTAssertNotNil(indexArray)
        XCTAssertEqual(indexArray, 2)
    }
    
    func testValueOutInRange() throws {
        //Given
        let array = [0, 1, 2, 3, 4, 5]
        
        //When
        let indexArray = array[safe: 7]
        
        //Then
        XCTAssertNil(indexArray)
    }
}

