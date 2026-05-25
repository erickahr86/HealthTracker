import Foundation

// MARK: - Strings
// Single source of truth for all user-facing localized text.
// Never use NSLocalizedString / hardcoded strings outside this file.

enum Strings {

    // MARK: - Errors

    enum Error {
        static var invalidURL: String            { L("error.invalid_url") }
        static var invalidResponse: String       { L("error.invalid_response") }
        static var keychainNotFound: String      { L("error.keychain.not_found") }
        static var keychainDuplicate: String     { L("error.keychain.duplicate") }

        static func api(statusCode: Int, message: String) -> String {
            String(format: L("error.api"), statusCode, message)
        }
        static func decoding(_ error: Swift.Error) -> String {
            String(format: L("error.decoding"), error.localizedDescription)
        }
        static func network(_ error: Swift.Error) -> String {
            String(format: L("error.network"), error.localizedDescription)
        }
        static func keychainUnexpected(_ status: Int32) -> String {
            String(format: L("error.keychain.unexpected"), status)
        }
    }

    // MARK: - Report

    enum Report {
        static var title: String               { L("report.title") }
        static var physicalActivity: String    { L("report.section.physical_activity") }
        static var restDay: String             { L("report.rest_day") }
        static var gym: String                 { L("report.gym") }
        static var noTraining: String          { L("report.no_training") }
        static var meals: String               { L("report.section.meals") }
        static var feeling: String             { L("report.section.feeling") }
        static var photoAttached: String       { L("report.photo_attached") }
        static var noData: String              { L("report.no_data") }

        static func steps(_ count: Int) -> String {
            String(format: L("report.steps"), count)
        }
        static func hydration(_ glasses: Int) -> String {
            String(format: L("report.hydration"), glasses)
        }
        static func energy(_ value: Int) -> String {
            String(format: L("report.energy"), value)
        }
        static func sleep(_ value: String) -> String {
            String(format: L("report.sleep"), value)
        }
        static func glucose(_ value: Int) -> String {
            String(format: L("report.glucose"), value)
        }
        static func bloodPressure(_ value: String) -> String {
            String(format: L("report.blood_pressure"), value)
        }
    }

    // MARK: - Today screen

    enum Today {
        // Sections
        static var activitySection:  String { L("today.section.activity") }
        static var exerciseSection:  String { L("today.section.exercise") }
        static var mealsSection:     String { L("today.section.meals") }
        static var hydrationSection: String { L("today.section.hydration") }
        static var healthSection:    String { L("today.section.health") }
        static var notesSection:     String { L("today.section.notes") }
        static var analysisSection:  String { L("today.section.analysis") }

        // Fields
        static var restDay:           String { L("today.rest_day") }
        static var stepsLabel:        String { L("today.steps.label") }
        static var stepsPlaceholder:  String { L("today.steps.placeholder") }
        static var energyLabel:       String { L("today.energy.label") }
        static var sleepLabel:        String { L("today.sleep.label") }
        static var sleepPlaceholder:  String { L("today.sleep.placeholder") }
        static var waterGlassesUnit:  String { L("today.water.unit") }
        static var glucoseLabel:      String { L("today.glucose.label") }
        static var glucosePlaceholder:String { L("today.glucose.placeholder") }
        static var bpLabel:           String { L("today.bp.label") }
        static var bpPlaceholder:     String { L("today.bp.placeholder") }
        static var notesPlaceholder:  String { L("today.notes.placeholder") }

        // Actions
        static var analyze:       String { L("today.analyze") }
        static var reanalyze:     String { L("today.reanalyze") }
        static var addLabel:      String { L("today.add.label") }
        static var cancelLabel:   String { L("today.cancel.label") }
        static var confirmLabel:  String { L("today.confirm.label") }
        static var errorTitle:    String { L("error.title") }

        // Exercise picker
        static var exerciseEmpty:         String { L("today.exercise.empty") }
        static var exercisePickerTitle:   String { L("today.exercise.picker.title") }
        static var searchExercisePlaceholder: String { L("today.exercise.search.placeholder") }
        static var weightLabel:           String { L("today.exercise.weight.label") }
        static var weightPlaceholder:     String { L("today.exercise.weight.placeholder") }

        // Meal picker
        static var mealSlotEmpty:        String { L("today.meal.slot.empty") }
        static var freeTextLabel:        String { L("today.meal.free_text.label") }
        static var freeTextSubtitle:     String { L("today.meal.free_text.subtitle") }
        static var freeTextPlaceholder:  String { L("today.meal.free_text.placeholder") }
        static var amountLabel:          String { L("today.meal.amount.label") }
        static var amountPlaceholder:    String { L("today.meal.amount.placeholder") }
        static var catalogLabel:         String { L("today.meal.catalog.label") }
        static var searchFoodPlaceholder:String { L("today.meal.search.placeholder") }

        static func mealPickerTitle(_ slotName: String) -> String {
            String(format: L("today.meal.picker.title"), slotName)
        }

        static func analyzedAt(_ date: Date) -> String {
            let formatted = date.formatted(date: .abbreviated, time: .shortened)
            return String(format: L("today.analyzed_at"), formatted)
        }
    }

    // MARK: - Private helper

    private static func L(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}
