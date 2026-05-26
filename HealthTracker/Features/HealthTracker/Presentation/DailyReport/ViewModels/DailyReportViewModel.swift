import Foundation
import SwiftUI
import Observation

// MARK: - DailyReportViewModel

@MainActor
@Observable
final class DailyReportViewModel {

    // MARK: - State

    var report:        DailyReport   = DailyReport()
    var exercises:     [Exercise]    = []
    var foods:         [Food]        = []
    var hydrationUnit: HydrationUnit = .deviceDefault
    var isLoading      = false
    var isAnalyzing    = false
    var errorMessage:  String?

    // MARK: - Private

    private let getTodayReport:   any GetOrCreateTodayReportUseCase
    private let saveReportUC:     any SaveDailyReportUseCase
    private let analyzeReportUC:  any AnalyzeReportWithAIUseCase
    private let getExercisesUC:   any GetExercisesUseCase
    private let getFoodsUC:       any GetFoodsUseCase
    private let preferencesRepo:  any UserPreferencesRepository

    private var isDataLoaded  = false
    private var autoSaveTask: Task<Void, Never>?

    // MARK: - Init

    init(factory: FeatureFactory) {
        getTodayReport  = factory.makeGetOrCreateTodayReportUseCase()
        saveReportUC    = factory.makeSaveDailyReportUseCase()
        analyzeReportUC = factory.makeAnalyzeReportWithAIUseCase()
        getExercisesUC  = factory.makeGetExercisesUseCase()
        getFoodsUC      = factory.makeGetFoodsUseCase()
        preferencesRepo = factory.userPreferencesRepository
    }

    // MARK: - Load

    func loadData() async {
        guard !isDataLoaded else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            async let r = getTodayReport.execute()
            async let e = getExercisesUC.execute(filter: nil)
            async let f = getFoodsUC.execute()
            report        = try await r
            exercises     = try await e
            foods         = try await f
            hydrationUnit = preferencesRepo.getHydrationUnit()
            isDataLoaded  = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Auto-save (0.8 s debounce)

    func scheduleAutoSave() {
        autoSaveTask?.cancel()
        autoSaveTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: 800_000_000)
            guard !Task.isCancelled else { return }
            try? await saveReportUC.execute(report)
        }
    }

    // MARK: - Exercise mutations

    func addExerciseLog(_ log: ExerciseLog) {
        report.exerciseLogs.append(log)
        scheduleAutoSave()
    }

    func removeExerciseLogs(at offsets: IndexSet) {
        report.exerciseLogs.remove(atOffsets: offsets)
        scheduleAutoSave()
    }

    // MARK: - Meal mutations

    func addMealLog(_ log: MealLog) {
        report.mealLogs.append(log)
        scheduleAutoSave()
    }

    func removeMealLogs(in slot: MealSlot, at offsets: IndexSet) {
        let slotIndices = report.mealLogs.indices.filter { report.mealLogs[$0].mealSlot == slot }
        let toRemove = IndexSet(offsets.map { slotIndices[$0] })
        report.mealLogs.remove(atOffsets: toRemove)
        scheduleAutoSave()
    }

    func mealLogs(for slot: MealSlot) -> [MealLog] {
        report.mealLogs.filter { $0.mealSlot == slot }
    }

    // MARK: - AI analysis

    func analyze() async {
        guard !isAnalyzing else { return }
        isAnalyzing = true
        errorMessage = nil
        defer { isAnalyzing = false }
        do {
            let result = try await analyzeReportUC.execute(report: report)
            // Use case already persisted; sync local copy
            report.analysisResult = result.rawText
            report.analysisDate   = result.createdAt
            report.trafficLight   = result.trafficLight
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Computed

    var hasAnalysis: Bool {
        report.analysisResult != nil
    }

    var formattedDate: String {
        report.date.formatted(date: .complete, time: .omitted)
    }

    /// Returns the suggested weight and unit for an exercise (last log today or exercise default).
    func suggestedWeight(for exercise: Exercise) -> (Double, WeightUnit) {
        if let last = report.exerciseLogs.last(where: { $0.exercise.id == exercise.id }) {
            return (last.weight, last.weightUnit)
        }
        return (exercise.defaultWeight, exercise.weightUnit)
    }

    /// Returns the suggested amount for a food item (last log today or food default).
    func suggestedAmount(for food: Food) -> Double {
        report.mealLogs
            .last(where: { $0.food?.id == food.id })
            .flatMap(\.amount) ?? food.defaultAmount
    }

    // MARK: - User preferences

    /// Re-reads all user preferences from storage.
    /// Call on every view appearance to pick up changes made in Settings
    /// without triggering a full report reload.
    func refreshPreferences() {
        hydrationUnit = preferencesRepo.getHydrationUnit()
    }

    /// Updates the hydration unit preference and persists it immediately.
    func updateHydrationUnit(_ unit: HydrationUnit) {
        hydrationUnit = unit
        preferencesRepo.setHydrationUnit(unit)
    }
}
