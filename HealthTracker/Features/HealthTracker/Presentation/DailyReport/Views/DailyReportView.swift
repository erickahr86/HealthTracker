import SwiftUI

// MARK: - MealSlot + Identifiable (UI extension, not domain)

extension MealSlot: Identifiable {
    public var id: String { rawValue }
}

// MARK: - DailyReportView

struct DailyReportView: View {

    @State private var vm: DailyReportViewModel
    @State private var showExercisePicker = false
    @State private var activeMealSlot: MealSlot?

    init(container: AppContainer) {
        _vm = State(wrappedValue: DailyReportViewModel(factory: container.featureFactory))
    }

    var body: some View {
        @Bindable var vm = vm

        NavigationStack {
            ZStack {
                Color.htBackground.ignoresSafeArea()

                if vm.isLoading {
                    ProgressView()
                        .tint(Color.htAccent)
                } else {
                    scrollContent
                }
            }
            .navigationTitle(vm.formattedDate)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if vm.report.trafficLight != nil {
                        TrafficLightBadge(vm.report.trafficLight, style: .dotWithLabel)
                    }
                }
            }
        }
        .task { await vm.loadData() }
        .onAppear {
            vm.refreshPreferences()
            Task { await vm.reloadCatalogs() }
        }
        .alert(
            Strings.Today.errorTitle,
            isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { if !$0 { vm.errorMessage = nil } }
            )
        ) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Scroll content

    @ViewBuilder
    private var scrollContent: some View {
        @Bindable var vm = vm

        ScrollView {
            VStack(spacing: HTSpacing.md) {

                // Activity
                ActivitySectionView(vm: vm)
                    .onChange(of: vm.report.isRestDay)   { vm.scheduleAutoSave() }
                    .onChange(of: vm.report.steps)       { vm.scheduleAutoSave() }
                    .onChange(of: vm.report.energyLevel) { vm.scheduleAutoSave() }
                    .onChange(of: vm.report.sleepHours)  { vm.scheduleAutoSave() }

                // Exercise — hidden on rest days
                if !vm.report.isRestDay {
                    ExerciseSectionView(
                        vm: vm,
                        onAdd: { showExercisePicker = true }
                    )
                }

                // Meals
                MealsSectionView(
                    vm: vm,
                    onAddInSlot: { activeMealSlot = $0 }
                )

                // Hydration
                HydrationSectionView(vm: vm)
                    .onChange(of: vm.report.waterGlasses) { vm.scheduleAutoSave() }

                // Health indicators
                HealthIndicatorsSectionView(vm: vm)
                    .onChange(of: vm.report.glucoseMgdl)   { vm.scheduleAutoSave() }
                    .onChange(of: vm.report.bloodPressure) { vm.scheduleAutoSave() }

                // Notes
                NotesSectionView(vm: vm)
                    .onChange(of: vm.report.notes) { vm.scheduleAutoSave() }

                // Existing analysis result
                if let text = vm.report.analysisResult {
                    AnalysisCardView(
                        text: text,
                        trafficLight: vm.report.trafficLight,
                        analysisDate: vm.report.analysisDate
                    )
                }

                // Analyze button
                HTButton(
                    vm.hasAnalysis ? Strings.Today.reanalyze : Strings.Today.analyze,
                    systemImage: "sparkles",
                    isLoading: vm.isAnalyzing
                ) {
                    Task { await vm.analyze() }
                }
                .padding(.top, HTSpacing.xs)
            }
            .padding(HTSpacing.md)
        }
        .sheet(isPresented: $showExercisePicker) {
            ExercisePickerSheet(
                exercises: vm.exercises,
                suggestedWeight: { vm.suggestedWeight(for: $0) },
                onConfirm: { vm.addExerciseLog($0) }
            )
        }
        .sheet(item: $activeMealSlot) { slot in
            FoodPickerSheet(
                slot: slot,
                foods: vm.foods,
                suggestedAmount: { vm.suggestedAmount(for: $0) },
                onConfirm: { vm.addMealLog($0) }
            )
        }
    }
}

// MARK: - Preview

#Preview {
    DailyReportView(container: .preview)
}
