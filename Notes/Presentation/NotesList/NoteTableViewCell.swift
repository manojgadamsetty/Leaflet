//
//  NoteTableViewCell.swift
//  Leaflet
//
//  Created by Manoj Gadamsetty on 19/07/25.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = MaterialColors.cardBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = MaterialColors.elevation2.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = MaterialColors.textPrimary
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = MaterialColors.textSecondary
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = MaterialColors.textHint
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tagsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let importantButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.setImage(UIImage(systemName: "star.fill"), for: .selected)
        button.tintColor = MaterialColors.secondary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = MaterialColors.textHint
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    weak var delegate: NoteTableViewCellDelegate?
    private var note: Note?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        
        cardView.addSubview(titleLabel)
        cardView.addSubview(contentLabel)
        cardView.addSubview(dateLabel)
        cardView.addSubview(tagsStackView)
        cardView.addSubview(importantButton)
        cardView.addSubview(moreButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Card view
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Important button
            importantButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            importantButton.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -8),
            importantButton.widthAnchor.constraint(equalToConstant: 24),
            importantButton.heightAnchor.constraint(equalToConstant: 24),
            
            // More button
            moreButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            moreButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            moreButton.widthAnchor.constraint(equalToConstant: 24),
            moreButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: importantButton.leadingAnchor, constant: -8),
            
            // Content label
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            // Tags stack view
            tagsStackView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 12),
            tagsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            tagsStackView.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -16),
            
            // Date label
            dateLabel.topAnchor.constraint(equalTo: tagsStackView.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupActions() {
        importantButton.addTarget(self, action: #selector(importantTapped), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    func configure(with note: Note) {
        self.note = note
        
        titleLabel.text = note.title.isEmpty ? "Untitled" : note.title
        contentLabel.text = note.content.isEmpty ? "No content" : note.content
        
        // Format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: note.updatedAt)
        
        // Configure important button
        importantButton.isSelected = note.isImportant
        importantButton.tintColor = note.isImportant ? MaterialColors.secondary : MaterialColors.textHint
        
        // Configure tags
        configureTags(note.tags)
        
        // Apply archived style
        if note.isArchived {
            cardView.alpha = 0.6
            titleLabel.textColor = MaterialColors.textSecondary
        } else {
            cardView.alpha = 1.0
            titleLabel.textColor = MaterialColors.textPrimary
        }
    }
    
    private func configureTags(_ tags: [String]) {
        // Clear existing tags
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new tags (limit to 3 visible)
        let visibleTags = Array(tags.prefix(3))
        
        for tag in visibleTags {
            let tagView = createTagLabel(text: tag)
            tagsStackView.addArrangedSubview(tagView)
        }
        
        // Add "more" indicator if there are additional tags
        if tags.count > 3 {
            let moreView = createTagLabel(text: "+\(tags.count - 3)")
            moreView.backgroundColor = MaterialColors.textHint.withAlphaComponent(0.15)
            tagsStackView.addArrangedSubview(moreView)
        }
        
        tagsStackView.isHidden = tags.isEmpty
    }
    
    private func createTagLabel(text: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = MaterialColors.primary.withAlphaComponent(0.1)
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = MaterialColors.primary
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
            label.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        return containerView
    }
    
    // MARK: - Actions
    @objc private func importantTapped() {
        guard let note = note else { return }
        delegate?.didTapImportant(for: note)
    }
    
    @objc private func moreTapped() {
        guard let note = note else { return }
        showMoreOptions(for: note)
    }
    
    private func showMoreOptions(for note: Note) {
        guard let delegate = delegate else { return }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Archive/Unarchive
        let archiveTitle = note.isArchived ? "Unarchive" : "Archive"
        let archiveAction = UIAlertAction(title: archiveTitle, style: .default) { _ in
            delegate.didTapArchive(for: note)
        }
        alert.addAction(archiveAction)
        
        // Delete
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            delegate.didTapDelete(for: note)
        }
        alert.addAction(deleteAction)
        
        // Cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present from the cell's view controller
        if let viewController = findViewController() {
            // For iPad
            if let popover = alert.popoverPresentationController {
                popover.sourceView = moreButton
                popover.sourceRect = moreButton.bounds
            }
            viewController.present(alert, animated: true)
        }
    }
    
    // MARK: - Helper
    override func prepareForReuse() {
        super.prepareForReuse()
        note = nil
        titleLabel.text = nil
        contentLabel.text = nil
        dateLabel.text = nil
        importantButton.isSelected = false
        importantButton.tintColor = MaterialColors.textHint
        cardView.alpha = 1.0
        titleLabel.textColor = MaterialColors.textPrimary
        
        // Clear tags
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}

// MARK: - UIView Extension
extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
