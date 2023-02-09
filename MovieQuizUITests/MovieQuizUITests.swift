//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Мурад Манапов on 28.01.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false

    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
                
        app.terminate()
        app = nil
    }
    
    func testYesButton() throws {
        
        sleep(3)
        let indexLabel = app.staticTexts["Index"]
        let firstScreen = app.images["Poster"]
        let firstPosterData = firstScreen.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondScreen = app.images["Poster"]
        let secondPosterData = secondScreen.screenshot().pngRepresentation
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    
    func testNoButton() throws {
        
        sleep(3)
        let indexLabel = app.staticTexts["Index"]
        let firstScreen = app.images["Poster"]
        let firstPosterData = firstScreen.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondScreen = app.images["Poster"]
        let secondPosterData = secondScreen.screenshot().pngRepresentation
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    
    func testAlert() throws {
        let alertTitle = app.alerts["Game result"]
        
        for _ in (1...10) {
            app.buttons["Yes"].tap()
            sleep(3)
        }
        
        XCTAssertTrue(alertTitle.exists)
        XCTAssertEqual(alertTitle.label, "Этот раунд окончен!")
        XCTAssertEqual(alertTitle.buttons.firstMatch.label, "Сыграть ещё раз")
    }
    
    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alertTitle = app.alerts["Game result"]
        alertTitle.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alertTitle.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
