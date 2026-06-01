import SwiftUI

// MARK: - APIKeySectionView
// Provider selector + secure API key input with save / delete controls.

struct APIKeySectionView: View {

    @Bindable var vm: SettingsViewModel
    @State private var showDeleteConfirm = false
    @FocusState private var isKeyFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            SectionHeader(Strings.Settings.aiSection, systemImage: "cpu")

            // Provider picker
            HStack {
                Text(Strings.Settings.providerLabel)
                    .font(HTTypography.body)
                Spacer()
                Picker("", selection: $vm.selectedProvider) {
                    ForEach(AIProvider.allCases, id: \.self) { provider in
                        Text(provider.displayName).tag(provider)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color.htAccent)
            }
            .onChange(of: vm.selectedProvider) { vm.onProviderChanged() }

            Divider().background(Color.htBorder)

            // Status row
            HStack {
                Text(Strings.Settings.apiKeyLabel)
                    .font(HTTypography.body)
                Spacer()
                keyStatusBadge
            }

            Divider().background(Color.htBorder)

            if vm.selectedProvider == .openAI {
                // OpenAI not yet implemented
                HStack(spacing: HTSpacing.sm) {
                    Image(systemName: "clock")
                        .foregroundStyle(.secondary)
                    Text(Strings.Settings.comingSoon)
                        .font(HTTypography.body)
                        .foregroundStyle(.secondary)
                }
            } else {
                // Key input
                SecureField(
                    vm.selectedProvider.apiKeyPlaceholder,
                    text: $vm.apiKeyInput
                )
                .focused($isKeyFieldFocused)
                .font(HTTypography.body)
                .textContentType(.password)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
                .onSubmit { vm.saveAPIKey() }

                Divider().background(Color.htBorder)

                // Action buttons
                HStack(spacing: HTSpacing.sm) {
                    Button {
                        isKeyFieldFocused = false
                        vm.saveAPIKey()
                    } label: {
                        Label(Strings.Settings.saveKey, systemImage: "checkmark.circle")
                            .font(HTTypography.body)
                    }
                    .disabled(vm.apiKeyInput.trimmingCharacters(in: .whitespaces).isEmpty
                              || vm.isSavingKey)
                    .tint(Color.htAccent)

                    Spacer()

                    if vm.hasStoredKey {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label(Strings.Settings.deleteKey, systemImage: "trash")
                                .font(HTTypography.body)
                        }
                    }
                }

                // Inline feedback
                if let feedback = vm.keyFeedback, feedback != .deleted {
                    feedbackRow(for: feedback)
                }
            }

            Divider().background(Color.htBorder)

            // Console link
            Link(destination: vm.selectedProvider.consoleURL) {
                HStack {
                    Label(vm.selectedProvider.consoleLabel, systemImage: "arrow.up.right.square")
                        .font(HTTypography.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .htCard()
        .confirmationDialog(
            Strings.Settings.deleteKeyTitle,
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(Strings.Settings.deleteKeyConfirm, role: .destructive) {
                vm.deleteAPIKey()
            }
            Button(Strings.Settings.cancelLabel, role: .cancel) { }
        } message: {
            Text(Strings.Settings.deleteKeyMessage)
        }
        .alert(
            Strings.Settings.errorTitle,
            isPresented: Binding(
                get: {
                    if case .error = vm.keyFeedback { return true }
                    return false
                },
                set: { if !$0 { vm.keyFeedback = nil } }
            )
        ) {
            Button("OK") { vm.keyFeedback = nil }
        } message: {
            if case .error(let msg) = vm.keyFeedback {
                Text(msg)
            }
        }
    }

    // MARK: - Sub-views

    private var keyStatusBadge: some View {
        Group {
            if vm.hasStoredKey {
                Label(Strings.Settings.keyStored, systemImage: "checkmark.seal.fill")
                    .font(HTTypography.caption)
                    .foregroundStyle(Color.htTrafficGreen)
            } else {
                Label(Strings.Settings.keyMissing, systemImage: "exclamationmark.triangle")
                    .font(HTTypography.caption)
                    .foregroundStyle(Color.htTrafficYellow)
            }
        }
    }

    @ViewBuilder
    private func feedbackRow(for feedback: SettingsViewModel.KeyFeedback) -> some View {
        switch feedback {
        case .saved:
            Label(Strings.Settings.keySavedFeedback, systemImage: "checkmark.circle.fill")
                .font(HTTypography.caption)
                .foregroundStyle(Color.htTrafficGreen)
                .transition(.opacity)
        case .deleted:
            EmptyView()
        case .error:
            EmptyView()
        }
    }
}
