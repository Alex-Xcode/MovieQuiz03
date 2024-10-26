
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
        sleep(3)
        let app = XCUIApplication()
        app.launch()
        
        // Ожидаем появления постера
        let posterImage = app.images["Poster"]
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: posterImage, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // Получаем скриншот первого постера
        let firstPosterData = posterImage.screenshot().pngRepresentation
        
        // Нажимаем кнопку "Yes"
        let yesButton = app.buttons["Yes"]
        XCTAssertTrue(yesButton.exists, "Кнопка «Да» должна присутствовать.")
        XCTAssertTrue(yesButton.isHittable, "Кнопка «Да» должна быть доступна для нажатия.")
        yesButton.tap()
        sleep(3)
        
        // Ожидаем изменения изображения
        let predicate = NSPredicate { _, _ -> Bool in
            let newPosterData = posterImage.screenshot().pngRepresentation
            return newPosterData != firstPosterData
        }
        expectation(for: predicate, evaluatedWith: nil, handler: nil)
        waitForExpectations(timeout: 40, handler: nil)
        
        // Получаем скриншот второго постера
        let secondPosterData = posterImage.screenshot().pngRepresentation
        
        // Проверяем, что постер изменился
        XCTAssertNotEqual(firstPosterData, secondPosterData, "Изображение на постере должно измениться после ответа на вопрос.")
        
        // Проверяем, что индекс обновился
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10", "Индекс должен обновиться на 2/10")
    }
    
    
    func testNoButton() {
        sleep(3)
        let app = XCUIApplication()
        app.launch()
        
        // Ожидаем появления постера
        let posterImage = app.images["Poster"]
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: posterImage, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // Получаем скриншот первого постера
        let firstPosterData = posterImage.screenshot().pngRepresentation
        
        // Нажимаем кнопку "No"
        let noButton = app.buttons["No"]
        XCTAssertTrue(noButton.exists, "Кнопка «Нет» должна присутствовать.")
        noButton.tap()
        sleep(3)
        
        // Ожидаем изменения изображения
        let predicate = NSPredicate { _, _ -> Bool in
            let newPosterData = posterImage.screenshot().pngRepresentation
            return newPosterData != firstPosterData
        }
        expectation(for: predicate, evaluatedWith: nil, handler: nil)
        waitForExpectations(timeout: 40, handler: nil)
        
        // Получаем скриншот второго постера
        let secondPosterData = posterImage.screenshot().pngRepresentation
        
        // Проверяем, что постер изменился
        XCTAssertNotEqual(firstPosterData, secondPosterData, "Изображение на постере должно измениться после ответа на вопрос.")
        
        // Проверяем, что индекс обновился
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10", "Индекс должен обновиться на 2/10")
    }
    
    
    func testShowAlert() {
        let app = XCUIApplication()
        app.launch()
        
        // Проходим через 10 вопросов
        for i in 1...10 {
            let yesButton = app.buttons["Yes"]
            XCTAssertTrue(yesButton.exists, "Кнопка «Да» должна присутствовать.")
            yesButton.tap()
            
            // Ожидаем обновления индекса вопроса
            let indexLabel = app.staticTexts["Index"]
            let expectedIndex = "\(i)/10"
            let predicate = NSPredicate(format: "label == %@", expectedIndex)
            expectation(for: predicate, evaluatedWith: indexLabel, handler: nil)
            waitForExpectations(timeout: 40, handler: nil)
        }
        
        // Ожидаем появления оповещения
        let alert = app.alerts["Этот раунд окончен!"]
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // Проверяем, что оповещение существует
        XCTAssertTrue(alert.exists, "После ответа на 10 вопросов должно появиться оповещение.")
        
        // Проверяем заголовок оповещения
        XCTAssertEqual(alert.label, "Этот раунд окончен!", "Заголовок оповещения должен быть 'Этот раунд окончен!'.")
        
        // Проверяем наличие кнопки на оповещении
        let alertButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(alertButton.exists, "На оповещении должна быть кнопка «Сыграть ещё раз».")
    }
    
    func testAlertDismiss() {
        sleep(3)
        let app = XCUIApplication()
        app.launch()
        
        // Проходим через 10 вопросов
        for i in 1...10 {
            let yesButton = app.buttons["Yes"]
            XCTAssertTrue(yesButton.exists, "Кнопка «Да» должна присутствовать.")
            yesButton.tap()
            
            // Ожидаем обновления индекса вопроса
            let indexLabel = app.staticTexts["Index"]
            let expectedIndex = "\(i)/10"
            let predicate = NSPredicate(format: "label == %@", expectedIndex)
            expectation(for: predicate, evaluatedWith: indexLabel, handler: nil)
            waitForExpectations(timeout: 40, handler: nil)
        }
        
        // Ожидаем появления оповещения
        let alert = app.alerts["Этот раунд окончен!"]
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // Проверяем, что оповещение существует
        XCTAssertTrue(alert.exists, "После ответа на 10 вопросов должно появиться оповещение.")
        
        // Проверяем наличие кнопки на оповещении
        let alertButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(alertButton.exists, "На оповещении должна быть кнопка «Сыграть ещё раз».")
        
        // Нажимаем кнопку на оповещении, чтобы закрыть его и перезапустить игру
        alertButton.tap()
        
        // Убеждаемся, что оповещение закрыто
        XCTAssertFalse(alert.exists, "Оповещение должно быть закрыто после нажатия на кнопку.")
        
        // Ожидаем сброса индекса на 1/10
        let indexLabel = app.staticTexts["Index"]
        let indexResetPredicate = NSPredicate(format: "label == '1/10'")
        expectation(for: indexResetPredicate, evaluatedWith: indexLabel, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // Проверяем, что индекс сброшен на 1/10
        XCTAssertEqual(indexLabel.label, "1/10", "После перезапуска игры индекс должен быть '1/10'.")
        
        // Проверяем, что новое изображение постера загружено
        let posterImage = app.images["Poster"]
        XCTAssertTrue(posterImage.exists, "Изображение постера должно присутствовать после перезапуска игры.")
        
        // Проверяем, что кнопки снова доступны
        XCTAssertTrue(app.buttons["Yes"].exists, "Кнопка «Да» должна быть доступна после перезапуска игры.")
        XCTAssertTrue(app.buttons["No"].exists, "Кнопка «Нет» должна быть доступна после перезапуска игры.")
    }
}
