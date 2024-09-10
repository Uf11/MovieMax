import Foundation

// MARK: - MovieManager

// Base class for movie management
class MovieManager {
    fileprivate let apiKey = "83d01f18538cb7a275147492f84c3698"

    // Perform the request and parse JSON
    func performRequest(with urlString: String, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if let error = error {
                    completionHandler(.failure(error))
                    return
                }
                if let safeData = data {
                    completionHandler(.success(safeData))
                }
            }
            task.resume()
        }
    }

    // Abstract method to parse JSON
    func parseJSON(_ data: Data, completionHandler: @escaping (Result<Any, Error>) -> Void) {
        fatalError("Subclasses need to implement the `parseJSON` method.")
    }
}

// MARK: - MovieDetailsManager

protocol MovieDetailsManagerDelegate {
    func didUpdateMovieDetails(_ movieManager: MovieDetailsManager, movie: DetailedMovie)
    func didFailWithError(error: Error)
}

class MovieDetailsManager: MovieManager {
    var baseURL = "https://api.themoviedb.org/3/movie"
    
    var onSuccess: ((DetailedMovie) -> Void)?
    var onFailure: ((Error) -> Void)?

    func fetchMovieDetails(for movieId: Int) {
        let urlString = "\(baseURL)/\(movieId)?api_key=\(apiKey)"
        performRequest(with: urlString) { result in
            switch result {
            case .success(let data):
                self.parseJSON(data) { result in
                    switch result {
                    case .success(let movie):
                        DispatchQueue.main.async {
                            self.onSuccess?(movie as! DetailedMovie)
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.onFailure?(error)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.onFailure?(error)
                }
            }
        }
    }
    
    override func parseJSON(_ data: Data, completionHandler: @escaping (Result<Any, Error>) -> Void) {
        let decoder = JSONDecoder()
        do {
            let detailedMovie = try decoder.decode(DetailedMovie.self, from: data)
            completionHandler(.success(detailedMovie))
        } catch {
            completionHandler(.failure(error))
        }
    }
}

// MARK: - MovieListManager

protocol MovieListManagerDelegate {
    func didUpdateMovies(_ movieManager: MovieListManager, movies: [BasicMovie])
    func didFailWithError(error: Error)
}

class MovieListManager: MovieManager {
    var baseURL = "https://api.themoviedb.org/3/discover/movie"
    static var page = 1  // Static member to keep track of the current page
    
    var onSuccess: (([BasicMovie]) -> Void)?
    var onFailure: ((Error) -> Void)?

    func fetchMovies() {
        let urlString = "\(baseURL)?api_key=\(apiKey)&page=\(MovieListManager.page)"
        performRequest(with: urlString) { result in
            switch result {
            case .success(let data):
                self.parseJSON(data) { result in
                    switch result {
                    case .success(let movies):
                        DispatchQueue.main.async {
                            if let movies = movies as? [BasicMovie]{
                                self.onSuccess?(movies)
                            } else {
                              print("error")
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.onFailure?(error)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.onFailure?(error)
                }
            }
        }
    }
    
    override func parseJSON(_ data: Data, completionHandler: @escaping (Result<Any, Error>) -> Void) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let results = json["results"] as? [[String: Any]] {
                
                let movieList = results.compactMap { movie -> BasicMovie? in
                    guard let id = movie["id"] as? Int,
                          let title = movie["title"] as? String,
                          let releaseDate = movie["release_date"] as? String,
                          let posterPath = movie["poster_path"] as? String else { return nil }

                    return BasicMovie(id: id, original_title: title, release_date: releaseDate, poster_path: posterPath)
                }
                
                completionHandler(.success(movieList))
            } else {
                completionHandler(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])))
            }
        } catch {
            completionHandler(.failure(error))
        }
    }
}
