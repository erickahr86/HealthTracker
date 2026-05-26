import SwiftUI

// MARK: - ReportDetailView
// Read-only detail view for a past DailyReport opened from the History tab.

struct ReportDetailView: View {

    let report: DailyReport

    var body: some View {
        ZStack {
            Color.htBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: HTSpacing.md) {

                    // Traffic light banner (only when analyzed)
                    if let tl = report.trafficLight {
                        TrafficLightBadge(tl, style: .banner)
                    }

                    // AI Analysis card
                    if let text = report.analysisResult {
                        AnalysisCardView(
                            text:         text,
                            trafficLight: report.trafficLight,
                            analysisDate: report.analysisDate
                        )
                    } else {
                        noAnalysisPlaceholder
                    }

                    // Activity summary
                    activityCard

                    // Meals
                    if !report.mealLogs.isEmpty {
                        mealsCard
                    }

                    // Health indicators
                    if hasHealthData {
                        healthCard
                    }

                    // Notes
                    if let notes = report.notes, !notes.isEmpty {
                        notesCard(notes)
                    }
                }
                .padding(HTSpacing.md)
            }
        }
        .navigationTitle(
            report.date.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
        )
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - No-analysis placeholder

    private var noAnalysisPlaceholder: some View {
        HStack(spacing: HTSpacing.sm) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: HTDimensions.Icon.md))
                .foregroundStyle(.secondary)
            Text(Strings.History.noAnalysis)
                .font(HTTypography.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .htCard()
    }

    // MARK: - Activity card

    private var activityCard: some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            SectionHeader(Strings.Today.activitySection, systemImage: "figure.run")

            if report.isRestDay {
                Text(Strings.Today.restDay)
                    .font(HTTypography.body)
                    .foregroundStyle(.secondary)
            } else {
                if let steps = report.steps {
                    infoRow(Strings.Today.stepsLabel, "\(steps)")
                }

                if report.exerciseLogs.isEmpty {
                    Text(Strings.History.noExercises)
                        .font(HTTypography.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(report.exerciseLogs) { log in
                        let weightText: String = {
                            guard log.weight > 0 else { return "—" }
                            let formatted = log.weight
                                .formatted(.number.precision(.fractionLength(0...1)))
                            return "\(formatted) \(log.weightUnit.displayName)"
                        }()
                        infoRow(log.exercise.name, weightText)
                    }
                }
            }

            if let energy = report.energyLevel {
                Divider().background(Color.htBorder)
                infoRow(Strings.Today.energyLabel, "\(energy)/10")
            }
            if let sleep = report.sleepHours, !sleep.isEmpty {
                infoRow(Strings.Today.sleepLabel, "\(sleep) h")
            }
            if report.waterGlasses > 0 {
                infoRow(Strings.Today.hydrationSection, "\(report.waterGlasses)")
            }
        }
        .htCard()
    }

    // MARK: - Meals card

    private var mealsCard: some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            SectionHeader(Strings.Today.mealsSection, systemImage: "fork.knife")

            ForEach(report.mealLogs) { log in
                let label  = log.food?.name ?? log.freeText ?? "—"
                let detail: String = {
                    if let amount = log.amount, let unit = log.food?.unit {
                        let formatted = amount.formatted(
                            .number.precision(.fractionLength(0...1))
                        )
                        return "\(formatted) \(unit)"
                    }
                    return ""
                }()
                infoRow("\(log.mealSlot.displayName): \(label)", detail)
            }
        }
        .htCard()
    }

    // MARK: - Health card

    private var healthCard: some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            SectionHeader(Strings.Today.healthSection, systemImage: "heart.text.square")

            if let glucose = report.glucoseMgdl {
                infoRow(Strings.Today.glucoseLabel, "\(glucose) mg/dL")
            }
            if let bp = report.bloodPressure, !bp.isEmpty {
                infoRow(Strings.Today.bpLabel, bp)
            }
        }
        .htCard()
    }

    // MARK: - Notes card

    private func notesCard(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            SectionHeader(Strings.Today.notesSection, systemImage: "note.text")
            Text(notes)
                .font(HTTypography.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .htCard()
    }

    // MARK: - Helpers

    private var hasHealthData: Bool {
        report.glucoseMgdl != nil ||
        (report.bloodPressure.map { !$0.isEmpty } ?? false)
    }

    @ViewBuilder
    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(HTTypography.body)
                .foregroundStyle(.primary)
            Spacer()
            if !value.isEmpty {
                Text(value)
                    .font(HTTypography.bodyMedium)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ReportDetailView(report: DailyReport(
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            exerciseLogs: [
                ExerciseLog(
                    exercise: Exercise(name: "Bench Press", defaultWeight: 80, muscleGroup: .superior),
                    weight: 82.5
                )
            ],
            mealLogs: [
                MealLog(mealSlot: .desayuno, freeText: "Oats with banana"),
                MealLog(food: Food(name: "Chicken Breast", unit: "g", defaultAmount: 200), mealSlot: .comida, amount: 200)
            ],
            waterGlasses:  4,
            energyLevel:   8,
            sleepHours:    "7.5",
            analysisResult: """
            [METABOLIC]
            Good macro balance. Estimated intake ~1850 kcal.
            [FUNCTIONAL]
            Upper body session completed. Appropriate volume.
            [LONGEVITY]
            Sleep optimal. Hydration adequate.
            [MISSION]
            Add a 20-min walk tomorrow.
            """,
            trafficLight: .green
        ))
    }
    .preferredColorScheme(.dark)
}
