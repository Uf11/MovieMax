import UIKit

// MARK: - MovieDetailViewController

class MovieDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private var movieManager = MovieDetailsManager()
    var id: Int? {
        didSet {
            if isViewLoaded {
                loadData()
            }
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var voteAverageLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var dropBackImageView: UIImageView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setClosures()
        
        if let safeId = id {
            movieManager.fetchMovieDetails(for: safeId)
        }
        self.navigationController?.navigationBar.tintColor = UIColor.gray;
    }
    
    // MARK: - UI Configuration
    
    private func configureUI() {
        // Set background color
        view.backgroundColor = UIColor.systemBackground
        
        // Customize labels
        let labels = [titleLabel, voteAverageLabel, voteCountLabel, revenueLabel, runtimeLabel, overviewLabel]
        labels.forEach { label in
            label?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            label?.textColor = UIColor.label
        }
        
        // Customize title label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = UIColor.systemBlue
        
        // Customize image view
        dropBackImageView.layer.cornerRadius = 10
        dropBackImageView.clipsToBounds = true
        dropBackImageView.contentMode = .scaleAspectFill
        
        // Add a shadow to the dropBackImageView
        dropBackImageView.layer.shadowColor = UIColor.black.cgColor
        dropBackImageView.layer.shadowOpacity = 0.7
        dropBackImageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        dropBackImageView.layer.shadowRadius = 8
    }
    
    // MARK: - Data Handling
    
    private func loadData() {
        guard let safeId = id else { return }
        movieManager.fetchMovieDetails(for: safeId)
    }
    
    // MARK: - UI Updates
    
    private func updateUI(with movie: DetailedMovie) {
        DispatchQueue.main.async {
            self.titleLabel.text = movie.original_title
            self.voteAverageLabel.text = "Vote Average: \(movie.vote_average)"
            
            // Set right-to-left attributes for voteCountLabel and revenueLabel
            let voteCountText = "Vote Count: \(movie.vote_count)"
            let revenueText = "Revenue: \(self.formatPoints(from: movie.revenue))"
            
            self.voteCountLabel.text = voteCountText
            self.revenueLabel.text = revenueText
            
            self.runtimeLabel.text = "Runtime: \(movie.movieDuration)"
            self.overviewLabel.text = movie.overview
            
            self.loadBackdropImage(from: movie.backdropURL)
        }
    }
    
    private func loadBackdropImage(from url: URL?) {
        if let url = url {
            dropBackImageView.loadImage(from: url)
        } else {
            dropBackImageView.image = UIImage(named: "placeholder")
        }
    }
    
    private func showAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - MovieDetailsManagerClosures

extension MovieDetailViewController {
    
    func setClosures() {
        self.movieManager.onSuccess = { movie in
            DispatchQueue.main.async {
                self.updateUI(with: movie)
            }
        }
        self.movieManager.onFailure = {error in
            DispatchQueue.main.async {
                self.showAlert(with: error.localizedDescription)
            }
        }
    }
}

extension MovieDetailViewController {
    func formatPoints(from: Int) -> String {
        
        let number = Double(from)
        let billion = number / 1_000_000_000
        let million = number / 1_000_000
        let thousand = number / 1000
        
        if number == 0 {
            return "Not Available"
        } else if billion >= 1.0 {
            return "$\(round(billion * 10) / 10)B"
        } else if million >= 1.0 {
            return "$\(round(million * 10) / 10)M"
        } else if thousand >= 1.0 {
            return "$\(round(thousand * 10) / 10)K"
        } else {
            return "$\(Int(number))"
        }
    }
}
