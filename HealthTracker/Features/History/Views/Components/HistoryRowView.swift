import SwiftUI

// MARK: - HistoryRowView
// Compact summary row for a past DailyReport shown in the History list.

struct HistoryRowView: View {

    let report: DailyReport

    var body: some View {
        HStack(spacing: HTSpacing.sm) {

            // Traffic light dot (neutral grey if no analysis)
            TrafficLightBadge(report.trafficLight, style: .dot)

            VStack(alignment: .leading, spacing: HTSpacing.xxs) {
                Text(report.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                    .font(HTTypography.subheadlineBold)
                    .foregroundStyle(.primary)

                Text(summaryLine)
                    .font(HTTypography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // AI analysis indicator
            if report.analysisResult != nil {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: HTDimensions.Icon.sm))
                    .foregroundStyle(Color.htAccent)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(HTSpacing.md)
        .background(Color.htSurface)
        .clipShape(RoundedRectangle(cornerRadius: HTDimensions.CornerRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: HTDimensions.CornerRadius.card)
                .strokeBorder(Color.htBorder, lineWidth: HTDimensions.Border.regular)
        )
    }

    // MARK: - Summary

    private var summaryLine: String {
        if report.isRestDay {
            return Strings.History.restDay
        }
        var parts: [String] = []
        let ec = report.exerciseLogs.count
        if ec > 0 { parts.append(Strings.History.exercises(ec)) }
        let mc = report.mealLogs.count
        if mc > 0 { parts.append(Strings.History.meals(mc)) }
        return parts.isEmpty ? Strings.History.noData : parts.joined(separator: " · ")
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: HTSpacing.xs) {
        HistoryRowView(report: DailyReport(
            date:          Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            exerciseLogs:  [ExerciseLog(exercise: Exercise(name: "Bench Press", defaultWeight: 80, muscleGroup: .superior), weight: 80)],
            mealLogs:      [MealLog(mealSlot: .desayuno, freeText: "Oats")],
            waterGlasses:  3,
            analysisResult: "...",
            trafficLight:  .green
        ))
        HistoryRowView(report: DailyReport(
            date:     Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            isRestDay: true,
            trafficLight: .yellow
        ))
        HistoryRowView(report: DailyReport(
            date:     Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        ))
    }
    .padding(HTSpacing.md)
    .background(Color.htBackground)
    .preferredColorScheme(.dark)
}
