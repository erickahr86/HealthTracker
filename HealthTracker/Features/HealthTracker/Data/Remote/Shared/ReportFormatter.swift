import Foundation

// MARK: - ReportFormatter

/// Formats a domain `DailyReport` into the plain-text string sent to the AI.
enum ReportFormatter {

    static func format(_ report: DailyReport, hydrationUnit: HydrationUnit) -> String {
        var lines: [String] = [Strings.Report.title, ""]

        // 1. Physical Activity
        lines.append(Strings.Report.physicalActivity)
        if report.isRestDay {
            lines.append(Strings.Report.restDay)
        } else {
            if !report.exerciseLogs.isEmpty {
                lines.append(Strings.Report.gym)
                for log in report.exerciseLogs {
                    lines.append("  \(log.exercise.name) \(log.weight)\(log.weightUnit.displayName)")
                }
            } else {
                lines.append(Strings.Report.noTraining)
            }
            if let steps = report.steps {
                lines.append(Strings.Report.steps(steps))
            }
        }

        // 1b. HealthKit Workouts (if any recorded by iPhone/Watch today)
        if !report.healthKitWorkouts.isEmpty {
            lines.append(Strings.Report.healthKitWorkoutsSection)
            for w in report.healthKitWorkouts {
                if let kcal = w.calories {
                    lines.append("  \(w.name) — \(w.durationMinutes) min (\(kcal) kcal)")
                } else {
                    lines.append("  \(w.name) — \(w.durationMinutes) min")
                }
            }
        }

        lines.append("")

        // 2. Meals
        lines.append(Strings.Report.meals)
        for slot in MealSlot.allCases {
            let slotLogs = report.mealLogs.filter { $0.mealSlot == slot }
            guard !slotLogs.isEmpty else { continue }

            let items: [String] = slotLogs.compactMap { log in
                if let food = log.food, let amount = log.amount {
                    return "\(formatAmount(amount)) \(food.unit) \(food.name)"
                } else if let freeText = log.freeText, !freeText.isEmpty {
                    return freeText
                }
                return nil
            }
            guard !items.isEmpty else { continue }

            let photoNote = slotLogs.contains { $0.photoData != nil } ? Strings.Report.photoAttached : ""
            lines.append("\(slot.displayName): \(items.joined(separator: ", "))\(photoNote)")
        }
        lines.append("")

        // 3. Hydration — uses the actual unit from user preferences
        let totalVol = hydrationUnit.formattedTotalVolume(count: report.waterGlasses)
        lines.append("3. Hydration: \(report.waterGlasses) × \(hydrationUnit.shortLabel) (\(totalVol))")
        lines.append("")

        // 4. Feeling
        lines.append(Strings.Report.feeling)
        var items: [String] = []
        if let energy = report.energyLevel              { items.append(Strings.Report.energy(energy)) }
        if let sleep  = report.sleepHours               { items.append(Strings.Report.sleep(sleep)) }
        if let gluc   = report.glucoseMgdl              { items.append(Strings.Report.glucose(gluc)) }
        if let bp     = report.bloodPressure            { items.append(Strings.Report.bloodPressure(bp)) }
        if let notes  = report.notes, !notes.isEmpty    { items.append(notes) }

        lines.append(items.isEmpty ? Strings.Report.noData : items.joined(separator: ", "))

        return lines.joined(separator: "\n")
    }

    // MARK: - Private

    /// Formats a Double removing trailing zeros (0.5 → "0.5", 4.0 → "4")
    private static func formatAmount(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(value)
    }
}
