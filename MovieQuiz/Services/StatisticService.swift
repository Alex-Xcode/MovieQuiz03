//
//  StatisticService.swift
//  MovieQuiz
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage = UserDefaults.standard
    
    private enum Keys: String {
        case gamesCount,
             bestGameCorrect,
             bestGameTotal,
             bestGameDate,
             totalCorrectAnswers,
             totalQuestions
    }
    
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let totalCorrect = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        
        guard totalQuestions > 0 else {
            return 0
        }
        
        return (Double(totalCorrect) / Double(totalQuestions)) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        let currentCorrect = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        storage.set(currentCorrect + count, forKey: Keys.totalCorrectAnswers.rawValue)
        
        let currentQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        storage.set(currentQuestions + amount, forKey: Keys.totalQuestions.rawValue)
        
        let currentBestGame = bestGame
        let newGame = GameResult(correct: count, total: amount, date: Date())
        
        if newGame.isBetterThan(currentBestGame) {
            bestGame = newGame
        }
    }
}
