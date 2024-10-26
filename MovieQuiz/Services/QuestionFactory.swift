import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let mostPopularMovies):
                    self?.movies = mostPopularMovies.items
                    self?.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self?.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = Int.random(in: 0..<self.movies.count)
            
            guard let movie = self.movies[safe: index],
                  let imageData = try? Data(contentsOf: movie.imageURL) else {
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: NSError(domain: "Image loading error", code: -1, userInfo: nil))
                }
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            let comparisonType = Bool.random() ? "больше" : "меньше"
            let ratingValue = self.selectRatingValue()
            let correctAnswer: Bool
            
            if comparisonType == "больше" {
                correctAnswer = rating > ratingValue
            } else {
                correctAnswer = rating < ratingValue
            }
            
            let questionText = "Рейтинг этого фильма \(comparisonType) чем \(ratingValue)?"
            let question = QuizQuestion(image: imageData, text: questionText, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async {
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    private func selectRatingValue() -> Float {
        let ratings = movies.compactMap { Float($0.rating) }
        guard !ratings.isEmpty else {
            return 7.0
        }
        
        let averageRating = ratings.reduce(0, +) / Float(ratings.count)
        return round(averageRating * 10) / 10
    }
}

