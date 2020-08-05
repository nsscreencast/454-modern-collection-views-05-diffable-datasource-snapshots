//
//  ViewController.swift
//  CompositionalEpisodes
//
//  Created by Ben Scheirman on 7/22/20.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    enum Section: Int, CaseIterable {
        case featured
        case recent
    }
    
    private var cancellables: Set<AnyCancellable> = []
    private var dataLoader = DataLoader()
    
    private var datasource: UICollectionViewDiffableDataSource<Section, Episode>!
    private var collectionView: UICollectionView!
    private var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Episodes"
        
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingIndicator)
        
        configureCollectionView()
        fetchData()
    }
    
    private func configureCollectionView() {
        let layout = LayoutManager().createLayout()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let featuredEpisodeCellRegistration = UICollectionView.CellRegistration<FeaturedEpisodeCell, Episode> { cell, indexPath, episode in
            cell.titleLabel.text = episode.title
            cell.subtitleLabel.text = "#\(episode.episodeNumber)"
            cell.imageView.setImage(with: episode.mediumArtworkUrl)
        }
        
        let episodeCellRegistration = UICollectionView.CellRegistration<EpisodeCell, Episode> { cell, indexPath, episode in
            cell.titleLabel.text = episode.title
            cell.subtitleLabel.text = "#\(episode.episodeNumber)"
            cell.imageView.setImage(with: episode.mediumArtworkUrl)
        }
        
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, model) -> UICollectionViewCell? in
            
            guard let sectionKind = Section(rawValue: indexPath.section) else {
                fatalError("Unhandled section: \(indexPath.section)")
            }
            
            switch sectionKind {
            case .featured:
                return collectionView.dequeueConfiguredReusableCell(using: featuredEpisodeCellRegistration, for: indexPath, item: model)
            
            case .recent:
                return collectionView.dequeueConfiguredReusableCell(using: episodeCellRegistration, for: indexPath, item: model)
            }
            
        })
    }
    
    private func fetchData() {
        dataLoader.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        dataLoader.dataChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateSnapshot()
            }
            .store(in: &cancellables)
        
        dataLoader.fetchData()
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Episode>()
        snapshot.appendSections(Section.allCases)
        
        struct Grouping {
            let episodes: [Episode]
            
            var featured: [Episode] {
                if episodes.count > 10 {
                    return Array(episodes.prefix(10))
                } else {
                    return []
                }
            }
            
            var recent: [Episode] {
                if episodes.count > 40 {
                    return Array(episodes.suffix(from: 10).prefix(30))
                } else {
                    return []
                }
            }
            
            var remaining: [Episode] {
                let usedCount = featured.count + recent.count
                if episodes.count > usedCount {
                    return Array(episodes.suffix(from: usedCount))
                } else {
                    return []
                }
            }
        }
        
        let grouping = Grouping(episodes: dataLoader.episodes)
        
        snapshot.appendItems(grouping.featured, toSection: .featured)
        snapshot.appendItems(grouping.recent, toSection: .recent)
        
        datasource.apply(snapshot)
    }
}
