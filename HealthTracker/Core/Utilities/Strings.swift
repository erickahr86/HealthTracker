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

    // MARK: - Private helper

    private static func L(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}
