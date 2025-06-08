//
//  NoteDetailViewController.swift
//  Leaflet
//
//  Created by Manoj Gadamsetty on 19/07/25.
//

import UIKit
import Combine

class NoteDetailViewController: UIViewController {
    
    // MARK: - Properties
    private var saveButton: UIBarButtonItem!
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.keyboardDismissMode = .interactive
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Note title..."
        textField.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        textField.textColor = MaterialColors.textPrimary
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    private lazy var contentTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.textColor = MaterialColors.textPrimary
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        return textView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Start writing your note..."
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = MaterialColors.textHint
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var importantToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.setImage(UIImage(systemName: "star.fill"), for: .selected)
        button.tintColor = MaterialColors.textSecondary
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(importantToggled), for: .touchUpInside)
        return button
    }()
    
    private lazy var tagsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false // Let the main scroll view handle scrolling
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "TagCell")
        return collectionView
    }()
    
    private lazy var addTagTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add tag..."
        textField.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        textField.textColor = MaterialColors.textPrimary
        textField.borderStyle = .roundedRect
        textField.backgroundColor = MaterialColors.cardBackground
        textField.layer.cornerRadius = 8
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.returnKeyType = .done
        return textField
    }()
    
    private lazy var tagsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var tagsHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Tags"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = MaterialColors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var importantStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var importantLabel: UILabel = {
        let label = UILabel()
        label.text = "Mark as Important"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = MaterialColors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    private let viewModel: NoteDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    private var tagsCollectionViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    init(viewModel: NoteDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            handleViewControllerDismissal()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = MaterialColors.background
        
        setupNavigationBar()
        setupScrollView()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        title = viewModel.navigationTitle
        
        // Save button
        saveButton = UIBarButtonItem(
            title: viewModel.saveButtonTitle,
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
        saveButton.tintColor = MaterialColors.primary
        navigationItem.rightBarButtonItem = saveButton
        
        // Cancel button
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem = cancelButton
        
        // Delete button (only for existing notes)
        if !viewModel.navigationTitle.contains("New") {
            let deleteButton = UIBarButtonItem(
                image: UIImage(systemName: "trash"),
                style: .plain,
                target: self,
                action: #selector(deleteTapped)
            )
            deleteButton.tintColor = MaterialColors.error
            navigationItem.rightBarButtonItems = [saveButton, deleteButton]
        }
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleTextField)
        contentView.addSubview(contentTextView)
        contentView.addSubview(placeholderLabel)
        
        // Important section
        importantStackView.addArrangedSubview(importantLabel)
        importantStackView.addArrangedSubview(UIView()) // spacer
        importantStackView.addArrangedSubview(importantToggleButton)
        contentView.addSubview(importantStackView)
        
        // Tags section
        tagsStackView.addArrangedSubview(tagsHeaderLabel)
        tagsStackView.addArrangedSubview(addTagTextField)
        tagsStackView.addArrangedSubview(tagsCollectionView)
        contentView.addSubview(tagsStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title text field
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Content text view
            contentTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            
            // Placeholder label
            placeholderLabel.topAnchor.constraint(equalTo: contentTextView.topAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            
            // Important section
            importantStackView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 24),
            importantStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            importantStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            importantStackView.heightAnchor.constraint(equalToConstant: 44),
            
            // Important toggle button
            importantToggleButton.widthAnchor.constraint(equalToConstant: 32),
            importantToggleButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Tags section
            tagsStackView.topAnchor.constraint(equalTo: importantStackView.bottomAnchor, constant: 24),
            tagsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tagsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tagsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            // Add tag text field
            addTagTextField.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Set up dynamic height constraint for tags collection view
        tagsCollectionViewHeightConstraint = tagsCollectionView.heightAnchor.constraint(equalToConstant: 50)
        tagsCollectionViewHeightConstraint?.isActive = true
    }
    
    private func setupBindings() {
        // Bind view model properties to UI
        viewModel.$title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.titleTextField.text = title
            }
            .store(in: &cancellables)
        
        viewModel.$content
            .receive(on: DispatchQueue.main)
            .sink { [weak self] content in
                self?.contentTextView.text = content
                self?.updatePlaceholder()
            }
            .store(in: &cancellables)
        
        viewModel.$isImportant
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isImportant in
                self?.importantToggleButton.isSelected = isImportant
                self?.updateImportantButtonAppearance()
            }
            .store(in: &cancellables)
        
        viewModel.$tags
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tagsCollectionView.reloadData()
                self?.updateTagsCollectionViewHeight()
            }
            .store(in: &cancellables)
        
        // Bind canSave state to save button
        viewModel.$hasUnsavedChanges
            .combineLatest(viewModel.$title)
            .map { (hasChanges: Bool, title: String) -> Bool in
                return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && hasChanges
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canSave in
                self?.saveButton.isEnabled = canSave
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    @objc private func saveTapped() {
        viewModel.saveNote()
    }
    
    @objc private func cancelTapped() {
        if viewModel.showDiscardChangesAlert() {
            showDiscardChangesAlert()
        } else {
            viewModel.discardChanges()
        }
    }
    
    @objc private func deleteTapped() {
        showDeleteConfirmation()
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    @objc private func importantToggled() {
        viewModel.toggleImportant()
    }
    
    // MARK: - Helper Methods
    private func updatePlaceholder() {
        placeholderLabel.isHidden = !contentTextView.text.isEmpty
    }
    
    private func updateImportantButtonAppearance() {
        let isSelected = importantToggleButton.isSelected
        importantToggleButton.tintColor = isSelected ? MaterialColors.secondary : MaterialColors.textSecondary
    }
    
    private func updateTagsCollectionViewHeight() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tagsCollectionView.layoutIfNeeded()
            let height = self.tagsCollectionView.collectionViewLayout.collectionViewContentSize.height
            self.tagsCollectionViewHeightConstraint?.constant = max(height, 50) // Minimum height of 50
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func handleViewControllerDismissal() {
        viewModel.cancelEditing()
    }
    
    private func showDiscardChangesAlert() {
        let alert = UIAlertController(
            title: "Discard Changes?",
            message: "You have unsaved changes. Are you sure you want to discard them?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Keep Editing", style: .cancel))
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
            self.viewModel.discardChanges()
        })
        
        present(alert, animated: true)
    }
    
    private func showDeleteConfirmation() {
        let alert = UIAlertController(
            title: "Delete Note?",
            message: "This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.viewModel.deleteNote()
        })
        
        present(alert, animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension NoteDetailViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        
        if textField == titleTextField {
            viewModel.title = newText
        } else if textField == addTagTextField {
            viewModel.newTag = newText
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            contentTextView.becomeFirstResponder()
        } else if textField == addTagTextField {
            viewModel.addTag()
            addTagTextField.text = ""
            addTagTextField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - UITextViewDelegate
extension NoteDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel.content = textView.text
        updatePlaceholder()
    }
}

// MARK: - UICollectionViewDataSource
extension NoteDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = viewModel.tags.count
        updateTagsCollectionViewHeight()
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCollectionViewCell
        let tag = viewModel.tags[indexPath.item]
        cell.configure(with: tag)
        cell.onDelete = { [weak self] in
            self?.viewModel.removeTag(at: indexPath.item)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension NoteDetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Optional: Handle tag selection
    }
}
