//
//  NotesListViewController.swift
//  Leaflet
//
//  Created by Manoj Gadamsetty on 19/07/25.
//

import UIKit
import Combine

class NotesListViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = MaterialColors.background
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.register(NoteTableViewCell.self, forCellReuseIdentifier: "NoteCell")
        return table
    }()
    
    private lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search notes..."
        search.searchBar.searchBarStyle = .minimal
        return search
    }()
    
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        button.tintColor = MaterialColors.primary
        return button
    }()
    
    private lazy var categorySegmentedControl: UISegmentedControl = {
        let items = NotesListViewModel.NoteCategory.allCases.map { $0.title }
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.backgroundColor = MaterialColors.cardBackground
        control.selectedSegmentTintColor = MaterialColors.primary
        control.setTitleTextAttributes([.foregroundColor: MaterialColors.onPrimary], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: MaterialColors.textPrimary], for: .normal)
        control.addTarget(self, action: #selector(categoryChanged), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = MaterialColors.textHint
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = MaterialColors.textSecondary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40)
        ])
        
        // Store references for updating
        view.tag = 100 // imageView
        titleLabel.tag = 101 // titleLabel
        
        return view
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshNotes), for: .valueChanged)
        return refresh
    }()
    
    // MARK: - Properties
    private let viewModel: NotesListViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(viewModel: NotesListViewModel) {
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
        viewModel.loadNotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshNotes()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Leaflet"
        view.backgroundColor = MaterialColors.background
        
        navigationItem.rightBarButtonItem = addButton
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Add subviews
        view.addSubview(categorySegmentedControl)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        tableView.refreshControl = refreshControl
        
        // Setup constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Category control
            categorySegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            categorySegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categorySegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categorySegmentedControl.heightAnchor.constraint(equalToConstant: 32),
            
            // Table view
            tableView.topAnchor.constraint(equalTo: categorySegmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Empty state view
            emptyStateView.topAnchor.constraint(equalTo: categorySegmentedControl.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        // Bind filtered notes
        viewModel.$filteredNotes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateEmptyState()
            }
            .store(in: &cancellables)
        
        // Bind loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        // Bind error messages
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showError(errorMessage)
            }
            .store(in: &cancellables)
        
        // Bind selected category
        viewModel.$selectedCategory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                guard let self = self else { return }
                if let index = NotesListViewModel.NoteCategory.allCases.firstIndex(of: category) {
                    self.categorySegmentedControl.selectedSegmentIndex = index
                }
                self.updateEmptyState()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        viewModel.addNewNote()
    }
    
    @objc private func categoryChanged() {
        let selectedIndex = categorySegmentedControl.selectedSegmentIndex
        let category = NotesListViewModel.NoteCategory.allCases[selectedIndex]
        viewModel.selectCategory(category)
    }
    
    @objc private func refreshNotes() {
        viewModel.refreshNotes()
    }
    
    // MARK: - Helper Methods
    private func updateEmptyState() {
        let isEmpty = viewModel.filteredNotes.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        
        if isEmpty {
            updateEmptyStateContent()
        }
    }
    
    private func updateEmptyStateContent() {
        guard let imageView = emptyStateView.viewWithTag(100) as? UIImageView,
              let titleLabel = emptyStateView.viewWithTag(101) as? UILabel else { return }
        
        imageView.image = UIImage(systemName: viewModel.emptyStateIcon)
        titleLabel.text = viewModel.emptyStateMessage
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NotesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteTableViewCell
        let note = viewModel.filteredNotes[indexPath.row]
        cell.configure(with: note)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NotesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let note = viewModel.filteredNotes[indexPath.row]
        viewModel.didSelectNote(note)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - UISearchResultsUpdating
extension NotesListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        viewModel.searchNotes(with: searchText)
    }
}

// MARK: - NoteTableViewCellDelegate
extension NotesListViewController: NoteTableViewCellDelegate {
    
    func didTapImportant(for note: Note) {
        viewModel.toggleNoteImportant(note)
    }
    
    func didTapArchive(for note: Note) {
        viewModel.archiveNote(note)
    }
    
    func didTapDelete(for note: Note) {
        let alert = UIAlertController(
            title: "Delete Note",
            message: "Are you sure you want to delete this note?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.viewModel.deleteNote(note)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - NoteTableViewCellDelegate Protocol
protocol NoteTableViewCellDelegate: AnyObject {
    func didTapImportant(for note: Note)
    func didTapArchive(for note: Note)
    func didTapDelete(for note: Note)
}
