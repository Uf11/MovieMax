import UIKit

class MovieTableViewCell: UITableViewCell {


    @IBOutlet weak var movieListTitleLabel: UILabel!
    
    @IBOutlet weak var moviePosterImageView: UIImageView!
    
    func setLabels(title: String, year: Int?) {
        let currentYear = Calendar.current.component(.year, from: Date())
        
        // Customize the movie title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        
        let titleAttributedString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        
        // Customize the movie year
        let yearString = year.map(String.init) ?? "Unknown Year"
        let yearAttributes: [NSAttributedString.Key: Any] = year == currentYear ? [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.systemRed
        ] : [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        let yearAttributedString = NSAttributedString(string: yearString, attributes: yearAttributes)
        
        // Combine title and year
        titleAttributedString.append(NSAttributedString(string: "\n"))
        titleAttributedString.append(yearAttributedString)
        
        movieListTitleLabel.attributedText = titleAttributedString
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        // Set rounded corners and shadow for the poster image
        moviePosterImageView.layer.cornerRadius = 8
        moviePosterImageView.clipsToBounds = true
        moviePosterImageView.layer.shadowColor = UIColor.black.cgColor
        moviePosterImageView.layer.shadowOpacity = 0.5
        moviePosterImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        moviePosterImageView.layer.shadowRadius = 4
        
        // Add padding to the cell
        contentView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
    }
}

import UIKit

class MoviesTableViewController: UIViewController {

    private var movies: [BasicMovie] = []
    private var filteredMovies: [BasicMovie] = []
    private var isSearching = false
    private var movieManager = MovieListManager()
    private var searchController: UISearchController!

    @IBOutlet weak var moviesTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        configureSearchController()
        setClousers()
        movieManager.fetchMovies() 
    }

    private func configureNavigationBar() {
        title = "MovieMax"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationController?.navigationBar.barTintColor = UIColor.systemBackground
        navigationItem.largeTitleDisplayMode = .automatic
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = UIColor.systemBackground
    
        
        // Set the title text attributes for standard title
        let titleTextAttributes: [NSAttributedString.Key: Any] = [
//            .foregroundColor: UIColor(red: 0, green: 0, blue: 1, alpha: 1),
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
        
        // Set the title text attributes for large title (if used)
        let largeTitleTextAttributes: [NSAttributedString.Key: Any] = [
//            .foregroundColor: UIColor(red: 0, green: 0, blue: 1, alpha: 1),
            .font: UIFont.systemFont(ofSize: 32, weight: .bold),
            .backgroundColor: UIColor.systemBackground,
        ]
        navigationController?.navigationBar.largeTitleTextAttributes = largeTitleTextAttributes

    }


    private func configureTableView() {
        moviesTableView.dataSource = self
        moviesTableView.delegate = self
        moviesTableView.rowHeight = 170
        moviesTableView.separatorStyle = .singleLine
        moviesTableView.separatorColor = UIColor.lightGray
        moviesTableView.backgroundColor = UIColor.systemGroupedBackground
    }

    private func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.backgroundColor = UIColor.white
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UISearchResultsUpdating

extension MoviesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        isSearching = !searchText.isEmpty
        filteredMovies = isSearching ? movies.filter { $0.original_title.lowercased().contains(searchText.lowercased()) } : []
        moviesTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension MoviesTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredMovies.count : movies.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == movies.count {
            let loadMoreCell = UITableViewCell(style: .default, reuseIdentifier: "loadMoreCell")
            loadMoreCell.textLabel?.text = "Tap to View More Movies"
            loadMoreCell.textLabel?.textAlignment = .center
            loadMoreCell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            loadMoreCell.textLabel?.textColor = UIColor.systemBlue
            loadMoreCell.selectionStyle = .none
            return loadMoreCell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "movieTablePrototypeCell", for: indexPath) as? MovieTableViewCell else {
                fatalError("The dequeued cell is not an instance of MovieTableViewCell.")
            }
            let movie = isSearching ? filteredMovies[indexPath.row] : movies[indexPath.row]
            cell.setLabels(title: movie.original_title, year: movie.year)
            
            cell.moviePosterImageView.image = UIImage(named: "placeholder")
            if let url = movie.posterURL {
                cell.moviePosterImageView.loadImage(from: url)
            }
            
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension MoviesTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == movies.count){
            movieManager.fetchMovies()
        } else {
            performSegue(withIdentifier: "goToDetails", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath =  moviesTableView.indexPathForSelectedRow {
            let movie = isSearching ? filteredMovies[indexPath.row] : movies[indexPath.row]
            if let detailVC = segue.destination as? MovieDetailViewController {
                detailVC.id = movie.id
            }
        }
    }
}

// MARK: - MovieManagerDelegate

extension MoviesTableViewController {

    func setClousers() {
        self.movieManager.onSuccess = { movies in
            self.movies += movies
            DispatchQueue.main.async {
                self.moviesTableView.reloadData()
            }
        }
        self.movieManager.onFailure = { error in
            print("Error: \(error)")
        }
    }

    func didFailWithError(error: Error) {
        print("Error: \(error)")
    }
}

// MARK: - UISearchBarDelegate

extension MoviesTableViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isSearching = !searchText.isEmpty
        filteredMovies = isSearching ? movies.filter { $0.original_title.lowercased().contains(searchText.lowercased()) } : []
        moviesTableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UIImageView Extension for Loading Images

extension UIImageView {
    func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("No image data or failed to create image")
                return
            }
            DispatchQueue.main.async {
                self?.image = image
            }
        }
        task.resume()
    }
}
