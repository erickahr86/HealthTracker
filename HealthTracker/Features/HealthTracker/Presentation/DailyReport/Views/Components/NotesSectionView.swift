import SwiftUI

// MARK: - NotesSectionView

struct NotesSectionView: View {

    @Bindable var vm: DailyReportViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            SectionHeader(Strings.Today.notesSection,
                          systemImage: "note.text")

            ZStack(alignment: .topLeading) {
                if notesValue.isEmpty {
                    Text(Strings.Today.notesPlaceholder)
                        .font(HTTypography.body)
                        .foregroundStyle(.tertiary)
                        .padding(EdgeInsets(top: 8, leading: 4, bottom: 0, trailing: 0))
                        .allowsHitTesting(false)
                }
                TextEditor(text: notesBinding)
                    .font(HTTypography.body)
                    .frame(minHeight: 80, maxHeight: 200)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
        }
        .htCard()
    }

    // MARK: - Binding

    private var notesValue: String { vm.report.notes ?? "" }

    private var notesBinding: Binding<String> {
        Binding(
            get: { vm.report.notes ?? "" },
            set: { vm.report.notes = $0.isEmpty ? nil : $0 }
        )
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var vm = DailyReportViewModel(factory: AppContainer.preview.featureFactory)
    NotesSectionView(vm: vm)
        .padding(HTSpacing.md)
        .background(Color.htBackground)
}
