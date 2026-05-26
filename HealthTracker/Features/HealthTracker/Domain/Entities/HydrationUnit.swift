import Foundation

// MARK: - HydrationUnit
// Represents the volume of a single logged "glass" (unit of hydration).
// The count stored in DailyReport.waterGlasses is unit-agnostic;
// HydrationUnit gives it meaning at display time.

enum HydrationUnit: String, Codable, CaseIterable, Hashable {

    // Imperial
    case glass8oz    // 240 ml  — standard US glass
    case glass16oz   // 473 ml  — medium bottle
    case glass40oz   // 1182 ml — large bottle (app legacy default)

    // Metric
    case ml250       // 250 ml  — standard metric glass
    case ml500       // 500 ml  — medium bottle
    case liter       // 1000 ml — 1-litre bottle

    // MARK: - Volume

    /// Volume in millilitres represented by one unit.
    var mlEquivalent: Double {
        switch self {
        case .glass8oz:  return 240
        case .glass16oz: return 473
        case .glass40oz: return 1182
        case .ml250:     return 250
        case .ml500:     return 500
        case .liter:     return 1000
        }
    }

    // MARK: - Display

    /// Short label shown inside the hydration card (e.g. "250 ml", "8 fl oz").
    var shortLabel: String {
        switch self {
        case .glass8oz:  return "8 fl oz"
        case .glass16oz: return "16 fl oz"
        case .glass40oz: return "40 fl oz"
        case .ml250:     return "250 ml"
        case .ml500:     return "500 ml"
        case .liter:     return "1 L"
        }
    }

    /// Full display name for the Settings picker (localized).
    var displayName: String {
        NSLocalizedString("hydration.unit.\(rawValue)", comment: "")
    }

    // MARK: - UI

    /// Number of drop icons shown in the hydration card.
    /// Calibrated so a full row ≈ 2–3 L (reasonable daily goal).
    var maxCount: Int {
        switch self {
        case .glass8oz:  return 10   // 2.4 L
        case .glass16oz: return 6    // 2.8 L
        case .glass40oz: return 4    // 4.7 L
        case .ml250:     return 10   // 2.5 L
        case .ml500:     return 6    // 3.0 L
        case .liter:     return 3    // 3.0 L
        }
    }

    // MARK: - Auto-detection

    /// Returns a sensible default derived from the device's locale / measurement system.
    /// - US / UK  → 8 fl oz glass
    /// - Metric   → 250 ml glass
    static var deviceDefault: HydrationUnit {
        switch Locale.current.measurementSystem {
        case .us, .uk: return .glass8oz
        default:       return .ml250
        }
    }

    // MARK: - Volume formatting

    /// Human-readable total volume string for a given count of this unit.
    func formattedTotalVolume(count: Int) -> String {
        let totalMl = Double(count) * mlEquivalent
        if totalMl >= 1000 {
            let liters = totalMl / 1000
            return String(format: "≈ %.1f L", liters)
        } else {
            return String(format: "≈ %.0f ml", totalMl)
        }
    }
}
