import UIKit

/// Material Design color palette for the Leaflet app
struct MaterialColors {
    
    // MARK: - Primary Colors
    static let primary = UIColor(red: 25/255, green: 118/255, blue: 210/255, alpha: 1.0)       // Blue 600
    static let primaryVariant = UIColor(red: 21/255, green: 101/255, blue: 192/255, alpha: 1.0) // Blue 700
    static let primaryLight = UIColor(red: 144/255, green: 202/255, blue: 249/255, alpha: 1.0)  // Blue 200
    
    // MARK: - Secondary Colors
    static let secondary = UIColor(red: 255/255, green: 193/255, blue: 7/255, alpha: 1.0)      // Amber 500
    static let secondaryVariant = UIColor(red: 255/255, green: 179/255, blue: 0/255, alpha: 1.0) // Amber 600
    
    // MARK: - Surface Colors
    static let surface = UIColor.systemBackground
    static let background = UIColor.systemGroupedBackground
    static let cardBackground = UIColor.secondarySystemGroupedBackground
    
    // MARK: - Text Colors
    static let onPrimary = UIColor.white
    static let onSecondary = UIColor.black
    static let onSurface = UIColor.label
    static let onBackground = UIColor.label
    static let textPrimary = UIColor.label
    static let textSecondary = UIColor.secondaryLabel
    static let textHint = UIColor.tertiaryLabel
    
    // MARK: - State Colors
    static let error = UIColor.systemRed
    static let success = UIColor.systemGreen
    static let warning = UIColor.systemOrange
    static let info = UIColor.systemBlue
    
    // MARK: - Divider & Outline
    static let divider = UIColor.separator
    static let outline = UIColor.opaqueSeparator
    
    // MARK: - Elevation Colors (for shadows)
    static let elevation1 = UIColor.black.withAlphaComponent(0.05)
    static let elevation2 = UIColor.black.withAlphaComponent(0.1)
    static let elevation3 = UIColor.black.withAlphaComponent(0.15)
    
    // MARK: - Note Status Colors
    static let noteDefault = UIColor.systemGray6
    static let noteImportant = UIColor.systemYellow
    static let noteArchived = UIColor.systemGray4
    static let noteDeleted = UIColor.systemRed.withAlphaComponent(0.1)
}

// MARK: - Material Color Extension
extension UIColor {
    
    /// Creates a material color with light and dark mode variants
    static func materialColor(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return dark
            default:
                return light
            }
        }
    }
    
    /// Material ripple effect color
    var rippleColor: UIColor {
        return self.withAlphaComponent(0.12)
    }
    
    /// Material pressed state color
    var pressedColor: UIColor {
        return self.withAlphaComponent(0.08)
    }
    
    /// Material hover state color
    var hoverColor: UIColor {
        return self.withAlphaComponent(0.04)
    }
}
