import SwiftUI

// MARK: - ExerciseCatalogView
// Grouped list of all exercises with add/delete custom exercise support.

struct ExerciseCatalogView: View {

    @Bindable var vm: CatalogViewModel

    @State private var showAddSheet      = false
    @State private var exerciseToDelete: Exercise? = nil

    var body: some View {
        ZStack {
            Color.htBackground.ignoresSafeArea()

            if vm.exercises.isEmpty {
                emptyView
            } else {
                exerciseList
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddExerciseSheet { name, weight, unit, group in
                await vm.addExercise(
                    name:          name,
                    defaultWeight: weight,
                    weightUnit:    unit,
                    muscleGroup:   group
                )
            }
        }
        .confirmationDialog(
            Strings.Catalog.deleteTitle,
            isPresented: Binding(
                get: { exerciseToDelete != nil },
                set: { if !$0 { exerciseToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(Strings.Catalog.deleteConfirm, role: .destructive) {
                if let e = exerciseToDelete {
                    Task { await vm.deleteExercise(e) }
                }
                exerciseToDelete = nil
            }
            Button(Strings.Catalog.cancel, role: .cancel) {
                exerciseToDelete = nil
            }
        } message: {
            Text(Strings.Catalog.deleteMessage)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .tint(Color.htAccent)
            }
        }
    }

    // MARK: - Empty state

    private var emptyView: some View {
        VStack(spacing: HTSpacing.md) {
            Image(systemName: "dumbbell")
                .font(.system(size: HTDimensions.Icon.xl))
                .foregroundStyle(.secondary)
            Text(Strings.Catalog.emptyExercises)
                .font(HTTypography.body)
                .foregroundStyle(.secondary)
            Button(Strings.Catalog.addExercise) {
                showAddSheet = true
            }
            .tint(Color.htAccent)
        }
    }

    // MARK: - List

    private var exerciseList: some View {
        List {
            ForEach(vm.exercisesByGroup, id: \.0) { group, exercises in
                Section(group.displayName) {
                    ForEach(exercises) { exercise in
                        exerciseRow(exercise)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private func exerciseRow(_ exercise: Exercise) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: HTSpacing.xxs) {
                Text(exercise.name)
                    .font(HTTypography.bodyMedium)
                    .foregroundStyle(.primary)

                let weightLine: String = exercise.defaultWeight > 0
                    ? Strings.Catalog.exerciseDefaultWeight(
                        exercise.defaultWeight,
                        exercise.weightUnit.displayName
                      )
                    : "—"

                Text(weightLine)
                    .font(HTTypography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                exerciseToDelete = exercise
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: HTDimensions.Icon.sm))
                    .foregroundStyle(Color.htTrafficRed)
            }
            .buttonStyle(.plain)
        }
    }

}

// MARK: - Preview

#Preview {
    NavigationStack {
        ExerciseCatalogView(vm: CatalogViewModel(
            factory:            AppContainer.preview.featureFactory,
            exerciseRepository: AppContainer.preview.exerciseRepository,
            foodRepository:     AppContainer.preview.foodRepository
        ))
    }
    .preferredColorScheme(.dark)
}
