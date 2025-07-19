//
//  TagCollectionViewCell.swift
//  Leaflet
//
//  Created by Manoj Gadamsetty on 19/07/25.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = MaterialColors.primary.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = MaterialColors.primary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = MaterialColors.primary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    var onDelete: (() -> Void)?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(tagLabel)
        containerView.addSubview(deleteButton)
        
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 32),
            
            // Tag label
            tagLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            tagLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            tagLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -4),
            
            // Delete button
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            deleteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 16),
            deleteButton.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    // MARK: - Configuration
    func configure(with tag: String) {
        tagLabel.text = tag
    }
    
    // MARK: - Actions
    @objc private func deleteButtonTapped() {
        onDelete?()
    }
    
    // MARK: - Size Calculation
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        let fittingSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        layoutAttributes.frame.size = fittingSize
        return layoutAttributes
    }
}

class AddTagCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = MaterialColors.primary.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = MaterialColors.primary.withAlphaComponent(0.3).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let addLabel: UILabel = {
        let label = UILabel()
        label.text = "+ Add Tag"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = MaterialColors.primary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(addLabel)
        
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 32),
            containerView.widthAnchor.constraint(equalToConstant: 80),
            
            // Add label
            addLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            addLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            addLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 12),
            addLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -12)
        ])
    }
    
    // MARK: - Size Calculation
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutAttributes.frame.size = CGSize(width: 80, height: 32)
        return layoutAttributes
    }
}
