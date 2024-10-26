
import XCTest

@testable import MovieQuiz

class MovieQuizUITests: XCTestCase {
    
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
    
    func testYesButton() {
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        let yesButton = app.buttons["Yes"]
        XCTAssertTrue(yesButton.exists, "Кнопка «Да» должна присутствовать.")
        
        yesButton.tap()
        
        let secondPoster = app.images["Poster"]
        
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: secondPoster)
        wait(for: [expectation], timeout: 5)
        
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertNotEqual(firstPosterData, secondPosterData, "Изображение на постере должно измениться после ответа на вопрос.")
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10", "Индекс вопроса должен увеличиваться после нажатия «Да».")
    }
    
    func testNoButton() {
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        let noButton = app.buttons["No"]
        XCTAssertTrue(noButton.exists, "Кнопка «Нет» должна присутствовать.")
        
        noButton.tap()
        
        let secondPoster = app.images["Poster"]
        
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: secondPoster)
        wait(for: [expectation], timeout: 5)
        
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertNotEqual(firstPosterData, secondPosterData, "Изображение на постере должно измениться после ответа на вопрос.")
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10", "Индекс вопроса должен увеличиться после нажатия «Нет».")
    }
    
    func testShowAlert() {
        for _ in 1...10 {
            let yesButton = app.buttons["Yes"]
            XCTAssertTrue(yesButton.exists, "Кнопка «Да» должна присутствовать.")
            yesButton.tap()
            
            let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: app.images["Poster"])
            wait(for: [expectation], timeout: 5)
        }
        
        let alert = app.alerts["Alert"]
        XCTAssertTrue(alert.exists, "После ответа на 10 вопросов должно появиться оповещение.")
        XCTAssertEqual(alert.label, "Этот раунд окончен!", "Заголовок оповещения должен быть 'Этот раунд окончен!'.")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз", "Надпись на кнопке оповещения должна быть 'Сыграть ещё раз'.")
    }
    
    func testAlertDismiss() {
        for _ in 1...10 {
            let noButton = app.buttons["No"]
            XCTAssertTrue(noButton.exists, "Кнопка «Нет» должна присутствовать.")
            noButton.tap()
            
            let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: app.images["Poster"])
            wait(for: [expectation], timeout: 5)
        }
        
        let alert = app.alerts["Alert"]
        XCTAssertTrue(alert.exists, "После ответа на 10 вопросов должно появиться оповещение.")
        
        alert.buttons.firstMatch.tap()
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.exists, "Метка индекса должна быть после отклонения оповещения.")
        XCTAssertEqual(indexLabel.label, "1/10", "После отключения оповещения индексная метка должна сбросить значение до «1/10».")
    }
}
