import SwiftUI

// MARK: - OnboardingView
// Two-step onboarding wizard:
//   1. Welcome  — branding + call to action
//   2. Exercise selection — Netflix-style chip picker grouped by training style

struct OnboardingView: View {

    @State private var vm: OnboardingViewModel
    let onComplete: () -> Void

    /// - Parameters:
    ///   - startingStep: Pass `.exerciseSelection` to skip the welcome screen
    ///     when re-opening from Settings after the initial onboarding is done.
    init(
        container:    AppContainer,
        startingStep: OnboardingViewModel.Step = .welcome,
        onComplete:   @escaping () -> Void
    ) {
        _vm = State(wrappedValue: OnboardingViewModel(factory: container.featureFactory,
                                                      startingStep: startingStep))
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            Color.htBackground.ignoresSafeArea()

            switch vm.step {
            case .welcome:
                welcomeStep
                    .transition(.asymmetric(
                        insertion: .identity,
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .exerciseSelection:
                exerciseSelectionStep
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .identity
                    ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.88), value: vm.step)
        .alert(
            Strings.Today.errorTitle,
            isPresented: Binding(
                get:  { vm.errorMessage != nil },
                set:  { if !$0 { vm.errorMessage = nil } }
            )
        ) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Welcome step

    private var welcomeStep: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 72, weight: .thin))
                .foregroundStyle(Color.htAccent)
                .padding(.bottom, HTSpacing.lg)

            // Titles
            Text(Strings.Onboarding.welcomeTitle)
                .font(HTTypography.largeTitle)
                .multilineTextAlignment(.center)

            Text(Strings.Onboarding.welcomeSubtitle)
                .font(HTTypography.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, HTSpacing.xs)
                .padding(.horizontal, HTSpacing.xl)

            Spacer()

            // Body copy
            Text(Strings.Onboarding.welcomeDetail)
                .font(HTTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, HTSpacing.xl)
                .padding(.bottom, HTSpacing.lg)

            // CTA
            HTButton(Strings.Onboarding.welcomeCTA, systemImage: "arrow.right") {
                withAnimation { vm.goToExerciseSelection() }
            }
            .padding(.horizontal, HTSpacing.md)

            // Skip
            Button(Strings.Onboarding.skip) {
                vm.skipOnboarding()
                onComplete()
            }
            .font(HTTypography.subheadline)
            .foregroundStyle(.secondary)
            .padding(.top, HTSpacing.sm)
            .padding(.bottom, HTSpacing.xxl)
        }
    }

    // MARK: - Exercise selection step

    private var exerciseSelectionStep: some View {
        VStack(spacing: 0) {
            // Header
            selectionHeader

            // Style tab bar
            styleTabBar
                .padding(.top, HTSpacing.sm)

            // Exercise chips
            exerciseScrollContent
                .padding(.top, HTSpacing.xs)

            // Bottom action bar
            bottomActionBar
        }
    }

    // MARK: Selection header

    private var selectionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(Strings.Onboarding.exerciseTitle)
                    .font(HTTypography.title2)
                Text(Strings.Onboarding.exerciseSubtitle)
                    .font(HTTypography.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if vm.selectedCount > 0 {
                Text(Strings.Onboarding.selectedCount(vm.selectedCount))
                    .font(HTTypography.captionBold)
                    .padding(.horizontal, HTSpacing.sm)
                    .padding(.vertical, HTSpacing.xxs)
                    .background(Color.htAccent.opacity(0.15))
                    .foregroundStyle(Color.htAccent)
                    .clipShape(Capsule())
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3), value: vm.selectedCount)
            }
        }
        .padding(.horizontal, HTSpacing.md)
        .padding(.top, HTSpacing.lg)
        .padding(.bottom, HTSpacing.xs)
    }

    // MARK: Style tab bar

    private var styleTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HTSpacing.xs) {
                ForEach(TrainingStyle.allCases, id: \.self) { style in
                    styleTab(for: style)
                }
            }
            .padding(.horizontal, HTSpacing.md)
        }
    }

    private func styleTab(for style: TrainingStyle) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                vm.activeStyle = style
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: style.systemImage)
                    .font(.system(size: 13, weight: .medium))
                Text(style.displayName)
                    .font(HTTypography.subheadlineBold)
            }
            .padding(.horizontal, HTSpacing.sm)
            .padding(.vertical, HTSpacing.xs)
            .background(vm.activeStyle == style ? Color.htAccent : Color.htSurfaceVariant)
            .foregroundStyle(vm.activeStyle == style ? Color.white : Color.primary)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(
                        vm.activeStyle == style ? Color.htAccent : Color.htBorder,
                        lineWidth: HTDimensions.Border.regular
                    )
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25), value: vm.activeStyle)
    }

    // MARK: Exercise scroll content

    private var exerciseScrollContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: HTSpacing.lg) {
                // Select all / none toggle for this style
                selectAllRow

                // Subcategory sections
                ForEach(vm.subcategories(for: vm.activeStyle), id: \.self) { group in
                    subcategorySection(group: group)
                }
            }
            .padding(.horizontal, HTSpacing.md)
            .padding(.bottom, HTSpacing.md)
        }
        .id(vm.activeStyle)   // forces scroll reset on tab change
    }

    private var selectAllRow: some View {
        let allSelected = vm.isAllSelected(for: vm.activeStyle)
        return HStack {
            Spacer()
            Button {
                withAnimation {
                    if allSelected {
                        vm.deselectAll(for: vm.activeStyle)
                    } else {
                        vm.selectAll(for: vm.activeStyle)
                    }
                }
            } label: {
                Text(allSelected ? Strings.Onboarding.deselectAll : Strings.Onboarding.selectAll)
                    .font(HTTypography.caption)
                    .foregroundStyle(Color.htAccent)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func subcategorySection(group: MuscleGroup) -> some View {
        let exercises = vm.exercises(for: vm.activeStyle, group: group)
        if !exercises.isEmpty {
            VStack(alignment: .leading, spacing: HTSpacing.sm) {
                // Section label
                Text(group.displayName.uppercased())
                    .font(HTTypography.caption2)
                    .foregroundStyle(.secondary)
                    .tracking(0.8)

                // Flowing chips
                WrapLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                    ForEach(exercises) { exercise in
                        ExerciseChipView(
                            exercise:   exercise,
                            isSelected: vm.isSelected(exercise),
                            action:     { vm.toggle(exercise) }
                        )
                    }
                }
            }
        }
    }

    // MARK: Bottom action bar

    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.htBorder)

            HStack(spacing: HTSpacing.sm) {
                // Skip link
                Button(Strings.Onboarding.skip) {
                    vm.skipOnboarding()
                    onComplete()
                }
                .font(HTTypography.subheadline)
                .foregroundStyle(.secondary)

                Spacer()

                // Confirm button
                HTButton(
                    Strings.Onboarding.done(vm.selectedCount),
                    systemImage: "checkmark",
                    isLoading: vm.isSaving
                ) {
                    Task {
                        if await vm.completeOnboarding() { onComplete() }
                    }
                }
                .frame(width: 180)
                .disabled(!vm.canComplete)
                .opacity(vm.canComplete ? 1 : 0.4)
                .animation(.easeInOut(duration: 0.2), value: vm.canComplete)
            }
            .padding(.horizontal, HTSpacing.md)
            .padding(.vertical, HTSpacing.sm)
        }
        .background(Color.htBackground)
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(container: .preview, onComplete: { })
}
