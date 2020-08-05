//
//  FeaturedEpisodeCell.swift
//  CompositionalEpisodes
//
//  Created by Ben Scheirman on 7/23/20.
//

import UIKit

class FeaturedEpisodeCell: UICollectionViewCell {
    static let reuseIdentifier = "FeaturedEpisodeCell"
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let imageView = RemoteImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configure() {
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 3
        
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 14
        imageView.layer.masksToBounds = true
        
        let separator = UIView()
        separator.backgroundColor = .quaternaryLabel
        
        let spacer = UIView()
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        let stack = UIStackView(arrangedSubviews: [separator, titleLabel, subtitleLabel, spacer, imageView])
        stack.axis = .vertical        
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        ])
        
        stack.setCustomSpacing(10, after: separator)
        stack.setCustomSpacing(10, after: subtitleLabel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.cancelImageRequest()
        imageView.image = nil
    }
}

