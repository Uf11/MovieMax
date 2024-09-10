//
//  MovieModel.swift
//  MovieMax
//
//  Created by Muhammad Usman Ghani on 09/09/2024.
//

import Foundation

// MARK: - Basic Movie
struct BasicMovie: Codable {
    let id: Int
    let original_title: String
    let release_date: String
    let poster_path: String?

    var posterURL: URL? {
        guard let path = poster_path else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    var year: Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: release_date) {
            let calendar = Calendar.current
            return calendar.component(.year, from: date)
        }
        return nil
    }
}

// MARK: - Detailed Movie
struct DetailedMovie: Codable {
    let original_title: String
    let backdrop_path: String?
    let vote_count: Int
    let vote_average: Double
    let overview: String
    let revenue: Int
    let runtime: Int?

    var backdropURL: URL? {
        guard let path = backdrop_path else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    var movieDuration: String {
        guard let runtime = runtime else { return "N/A" }
        let hours = runtime / 60
        let minutes = runtime % 60
        return "\(hours)H \(minutes)M"
    }
}
