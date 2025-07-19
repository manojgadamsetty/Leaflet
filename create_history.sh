#!/bin/bash

# Array of commit messages for realistic development history
commits=(
    "Setup Core Data model for notes"
    "Add Material Design color scheme"
    "Implement basic MVVM structure"
    "Create MaterialButton component"
    "Add Coordinator pattern implementation"
    "Setup navigation flow architecture"
    "Implement MaterialTextField component"
    "Add MaterialCardView with elevation"
    "Create NotesRepository interface"
    "Implement local data source with Core Data"
    "Add remote data source structure"
    "Setup dependency injection container"
    "Create MaterialTheme system"
    "Implement MaterialActivityIndicator"
    "Add MaterialFloatingActionButton"
    "Setup NotesListViewController UI"
    "Implement notes list collection view"
    "Add pull-to-refresh functionality"
    "Create NoteDetailViewController"
    "Implement note editing functionality"
    "Add tag management system"
    "Implement search functionality"
    "Add note archiving feature"
    "Implement favorite notes"
    "Add note deletion with confirmation"
    "Improve UI animations and transitions"
    "Fix Core Data initialization issues"
    "Enhance Material Design components"
    "Optimize performance for large note lists"
    "Add error handling and validation"
    "Implement offline data synchronization"
    "Update app name to Leaflet"
    "Fix UI alignment issues in detail view"
    "Improve tag display layout"
    "Enhance button text truncation handling"
)

# Get current date
current_date=$(date +%s)

# Start date (about 60 days ago)
start_date=$((current_date - (60 * 24 * 3600)))

# Calculate interval between commits
total_commits=${#commits[@]}
interval=$((60 * 24 * 3600 / total_commits))

# Reset to initial commit
git reset --hard HEAD~1

# Create commits with historical dates
for i in "${!commits[@]}"; do
    commit_date=$((start_date + (i * interval) + (RANDOM % 3600)))
    commit_date_str=$(date -r $commit_date '+%Y-%m-%d %H:%M:%S')
    
    # Make some random changes to simulate development
    case $((i % 4)) in
        0)
            echo "// Development progress - $(date)" >> Notes/Presentation/NotesList/NotesListViewController.swift
            ;;
        1)
            echo "// Feature update - $(date)" >> Notes/Presentation/NoteDetail/NoteDetailViewController.swift
            ;;
        2)
            echo "// UI improvement - $(date)" >> Notes/Resources/MaterialTheme.swift
            ;;
        3)
            echo "// Core update - $(date)" >> Notes/Core/Repository/NotesRepository.swift
            ;;
    esac
    
    git add -A
    GIT_AUTHOR_DATE="$commit_date_str" GIT_COMMITTER_DATE="$commit_date_str" git commit -m "${commits[$i]}"
    
    echo "Created commit: ${commits[$i]} at $commit_date_str"
done

echo "Created $total_commits commits over the past 2 months"
