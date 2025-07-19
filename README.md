# 🍃 Leaflet - iOS Notes App

A beautiful, modern iOS notes application built with Swift and Material Design principles.

[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org/)
[![Xcode](https://img.shields.io/badge/Xcode-14.0+-blue.svg)](https://developer.apple.com/xcode/)

## ✨ Features

### 🗂️ Core Functionality
- **Create & Edit Notes**: Rich text editing with intuitive interface
- **Tag Management**: Organize notes with customizable tags
- **Search & Filter**: Powerful search across all notes and tags
- **Favorites**: Mark important notes for quick access
- **Archive System**: Keep notes organized without deletion

### 🎨 Design & UI
- **Material Design 3**: Modern, beautiful interface following Google's latest design system
- **Dark & Light Themes**: Automatic theme switching based on system preferences
- **Smooth Animations**: Delightful micro-interactions throughout the app
- **Responsive Layout**: Optimized for all iPhone screen sizes

### 🏗️ Architecture
- **MVVM Pattern**: Clean, testable architecture
- **Coordinator Pattern**: Flexible navigation flow management
- **Repository Pattern**: Abstract data layer with offline-first approach
- **Dependency Injection**: Modular, testable code structure

### 💾 Data & Performance
- **Core Data Integration**: Reliable local persistence
- **Offline-First**: Full functionality without internet connection
- **Performance Optimized**: Smooth scrolling even with thousands of notes
- **Data Validation**: Comprehensive error handling and validation

## 🛠️ Technical Stack

### Languages & Frameworks
- **Swift 5.7+**: Modern Swift with latest language features
- **UIKit**: Native iOS interface framework
- **Core Data**: Apple's persistence framework
- **Combine**: Reactive programming for data binding

### Architecture Patterns
- **MVVM (Model-View-ViewModel)**: Separation of concerns
- **Coordinator Pattern**: Navigation management
- **Repository Pattern**: Data access abstraction
- **Protocol-Oriented Programming**: Flexible, testable code

### Design System
- **Material Design 3**: Google's latest design language
- **Custom UI Components**: Reusable Material components
- **Typography Scale**: Consistent text styling
- **Color System**: Accessible, beautiful color palette

## 📱 Screenshots

*Coming soon - Screenshots will be added once the app is running in simulator*

## 🚀 Getting Started

### Prerequisites
- Xcode 14.0 or later
- iOS 15.0+ deployment target
- macOS 12.0+ for development

### Installation
1. Clone the repository
```bash
git clone https://github.com/manojgadamsetty/Leaflet.git
```

2. Open the project in Xcode
```bash
cd Leaflet
open Leaflet.xcodeproj
```

3. Build and run the project
- Select your target device or simulator
- Press `Cmd + R` to build and run

## 🏗️ Project Structure

```
Leaflet/
├── Notes/
│   ├── Core/
│   │   ├── Coordinator/           # Navigation coordination
│   │   ├── DI/                    # Dependency injection
│   │   ├── Networking/            # API layer (future sync)
│   │   ├── Persistence/           # Core Data stack
│   │   └── Repository/            # Data access layer
│   ├── Domain/
│   │   ├── Models/                # Domain models
│   │   └── UseCases/              # Business logic
│   ├── Presentation/
│   │   ├── MaterialUI/            # Custom UI components
│   │   ├── NotesList/             # Notes list feature
│   │   └── NoteDetail/            # Note detail feature
│   └── Resources/
│       ├── MaterialTheme.swift    # Design system
│       └── MaterialColors.swift   # Color definitions
├── NotesTests/                    # Unit tests
├── NotesUITests/                  # UI tests
└── README.md
```

## 🎯 Roadmap

### Upcoming Features
- [ ] Cloud synchronization
- [ ] Rich text formatting
- [ ] Image attachments
- [ ] Voice notes
- [ ] Collaborative editing
- [ ] Export options (PDF, Markdown)
- [ ] Widget support
- [ ] Apple Watch companion app

### Technical Improvements
- [ ] Unit test coverage increase
- [ ] UI test automation
- [ ] Performance monitoring
- [ ] Accessibility enhancements
- [ ] Localization support

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Manoj Gadamsetty**
- GitHub: [@manojgadamsetty](https://github.com/manojgadamsetty)
- Email: manojgadamsetty@gmail.com

## 🙏 Acknowledgments

- Material Design team at Google for the amazing design system
- Apple for the excellent iOS development tools
- The iOS developer community for inspiration and support

---

⭐ If you found this project helpful, please give it a star!
