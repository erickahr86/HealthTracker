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

    // MARK: - Settings screen

    enum Settings {
        static var title:               String { L("settings.title") }

        // AI section
        static var aiSection:           String { L("settings.section.ai") }
        static var providerLabel:       String { L("settings.provider.label") }
        static var apiKeyLabel:         String { L("settings.api_key.label") }
        static var apiKeyPlaceholder:   String { L("settings.api_key.placeholder") }
        static var keyStored:           String { L("settings.api_key.stored") }
        static var keyMissing:          String { L("settings.api_key.missing") }
        static var saveKey:             String { L("settings.api_key.save") }
        static var deleteKey:           String { L("settings.api_key.delete") }
        static var keySavedFeedback:    String { L("settings.api_key.saved_feedback") }
        static var getKeyHint:          String { L("settings.api_key.get_hint") }
        static var deleteKeyTitle:      String { L("settings.delete_key.title") }
        static var deleteKeyMessage:    String { L("settings.delete_key.message") }
        static var deleteKeyConfirm:    String { L("settings.delete_key.confirm") }
        static var cancelLabel:         String { L("settings.cancel") }

        // Measurements section
        static var measurementsSection: String { L("settings.section.measurements") }
        static var hydrationUnitLabel:  String { L("settings.hydration.label") }
        static var measurementsFooter:  String { L("settings.measurements.footer") }

        // About section
        static var aboutSection:        String { L("settings.section.about") }
        static var versionLabel:        String { L("settings.version.label") }
        static var anthropicDocs:       String { L("settings.anthropic.docs") }

        // Catalog
        static var catalogSection:      String { L("settings.section.catalog") }
        static var exerciseCatalog:     String { L("settings.exercise_catalog") }
        static var exerciseCatalogHint: String { L("settings.exercise_catalog.hint") }

        // Shared
        static var errorTitle:          String { L("error.title") }
    }

    // MARK: - Onboarding

    enum Onboarding {
        // Welcome step
        static var welcomeTitle:    String { L("onboarding.welcome.title") }
        static var welcomeSubtitle: String { L("onboarding.welcome.subtitle") }
        static var welcomeDetail:   String { L("onboarding.welcome.detail") }
        static var welcomeCTA:      String { L("onboarding.welcome.cta") }

        // Exercise selection step
        static var exerciseTitle:   String { L("onboarding.exercises.title") }
        static var exerciseSubtitle:String { L("onboarding.exercises.subtitle") }
        static var selectAll:       String { L("onboarding.exercises.select_all") }
        static var deselectAll:     String { L("onboarding.exercises.deselect_all") }
        static var skip:            String { L("onboarding.exercises.skip") }

        static func selectedCount(_ n: Int) -> String {
            String(format: L("onboarding.exercises.selected_count"), n)
        }
        static func done(_ n: Int) -> String {
            n == 0 ? L("onboarding.exercises.done_empty") : String(format: L("onboarding.exercises.done"), n)
        }
    }

    // MARK: - Private helper

    private static func L(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}
