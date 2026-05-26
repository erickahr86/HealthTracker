import SwiftUI

// MARK: - APIKeySectionView
// Provider selector + secure API key input with save / delete controls.

struct APIKeySectionView: View {

    @Bindable var vm: SettingsViewModel
    @State private var showDeleteConfirm = false
    @FocusState private var isKeyFieldFocused: Bool

    var body: some View {
        Section {
            // Provider picker
            Picker(Strings.Settings.providerLabel, selection: $vm.selectedProvider) {
                ForEach(AIProvider.allCases, id: \.self) { provider in
                    Text(provider.displayName).tag(provider)
                }
            }
            .onChange(of: vm.selectedProvider) { vm.onProviderChanged() }

            // Status row
            HStack {
                Text(Strings.Settings.apiKeyLabel)
                Spacer()
                keyStatusBadge
            }

            // Key input — placeholder adapts to the selected provider
            SecureField(
                vm.selectedProvider.apiKeyPlaceholder,
                text: $vm.apiKeyInput
            )
            .focused($isKeyFieldFocused)
            .textContentType(.password)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .submitLabel(.done)
            .onSubmit { vm.saveAPIKey() }

            // Action buttons
            HStack(spacing: HTSpacing.sm) {
                // Save
                Button {
                    isKeyFieldFocused = false
                    vm.saveAPIKey()
                } label: {
                    Label(Strings.Settings.saveKey, systemImage: "checkmark.circle")
                }
                .disabled(vm.apiKeyInput.trimmingCharacters(in: .whitespaces).isEmpty
                          || vm.isSavingKey)
                .tint(Color.htAccent)

                Spacer()

                // Delete (only when a key is stored)
                if vm.hasStoredKey {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label(Strings.Settings.deleteKey, systemImage: "trash")
                    }
                }
            }

            // Inline feedback (saved / deleted) — auto-clears after 2 s
            if let feedback = vm.keyFeedback, feedback != .deleted {
                feedbackRow(for: feedback)
            }

        } header: {
            Text(Strings.Settings.aiSection)
        } footer: {
            Link(destination: vm.selectedProvider.consoleURL) {
                Label(vm.selectedProvider.consoleLabel, systemImage: "arrow.up.right.square")
                    .font(HTTypography.caption)
            }
        }
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
            EmptyView()  // handled by alert
        }
    }
}
