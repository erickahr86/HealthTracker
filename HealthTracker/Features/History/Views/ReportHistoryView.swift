import SwiftUI

// MARK: - ReportHistoryView
// Tab 2 — chronological list of past daily reports.

struct ReportHistoryView: View {

    @State private var vm: ReportHistoryViewModel
    @State private var selectedReport: DailyReport? = nil
    @State private var reportToDelete: DailyReport? = nil

    init(container: AppContainer) {
        _vm = State(wrappedValue: ReportHistoryViewModel(
            factory:          container.featureFactory,
            reportRepository: container.dailyReportRepository
        ))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.htBackground.ignoresSafeArea()

                Group {
                    if vm.isLoading {
                        ProgressView()
                            .tint(Color.htAccent)
                    } else if vm.reports.isEmpty {
                        emptyView
                    } else {
                        listView
                    }
                }
            }
            .navigationTitle(Strings.History.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedReport) { report in
                ReportDetailView(report: report)
            }
        }
        .task { await vm.loadData() }
        .confirmationDialog(
            Strings.History.deleteTitle,
            isPresented: Binding(
                get: { reportToDelete != nil },
                set: { if !$0 { reportToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(Strings.History.deleteConfirm, role: .destructive) {
                if let r = reportToDelete {
                    Task { await vm.deleteReport(r) }
                }
                reportToDelete = nil
            }
            Button(Strings.History.cancel, role: .cancel) {
                reportToDelete = nil
            }
        } message: {
            Text(Strings.History.deleteMessage)
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

    // MARK: - Empty state

    private var emptyView: some View {
        VStack(spacing: HTSpacing.md) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: HTDimensions.Icon.xl))
                .foregroundStyle(.secondary)
            Text(Strings.History.emptyTitle)
                .font(HTTypography.title3)
                .foregroundStyle(.primary)
            Text(Strings.History.emptySubtitle)
                .font(HTTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, HTSpacing.xl)
        }
    }

    // MARK: - Report list

    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: HTSpacing.xs) {
                ForEach(vm.reports) { report in
                    Button {
                        selectedReport = report
                    } label: {
                        HistoryRowView(report: report)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            reportToDelete = report
                        } label: {
                            Label(Strings.History.deleteConfirm, systemImage: "trash")
                        }
                    }
                }
            }
            .padding(HTSpacing.md)
        }
        .refreshable {
            await vm.loadData()
        }
    }
}

// MARK: - Preview

#Preview {
    ReportHistoryView(container: .preview)
}
