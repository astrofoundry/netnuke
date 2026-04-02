import SwiftUI

@main
struct NetNukeApp: App {
    @State private var viewModel = NetworkViewModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(viewModel: viewModel)
        } label: {
            Image(systemName: viewModel.isNetworkEnabled ? "shield" : "shield.slash")
                .symbolRenderingMode(.palette)
                .foregroundStyle(viewModel.isNetworkEnabled ? .green : .red)
        }
        .menuBarExtraStyle(.window)
    }
}
