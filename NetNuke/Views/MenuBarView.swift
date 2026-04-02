import SwiftUI

struct MenuBarView: View {
    var viewModel: NetworkViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: Binding(
                get: { viewModel.isNetworkEnabled },
                set: { _ in viewModel.toggle() }
            )) {
                Text(viewModel.isNetworkEnabled ? "Network Active" : "Network Killed")
                    .font(.headline)
            }
            .toggleStyle(.switch)
            .disabled(viewModel.isProcessing)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 220)
    }
}
