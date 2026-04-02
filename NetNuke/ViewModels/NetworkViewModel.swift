import Observation

@Observable
@MainActor
final class NetworkViewModel {
    var isNetworkEnabled: Bool = true
    var isProcessing: Bool = false
    var errorMessage: String?

    init() {
        refreshState()
    }

    func toggle() {
        guard !isProcessing else { return }
        isProcessing = true
        errorMessage = nil

        do {
            let services = try NetworkService.listServices()

            if isNetworkEnabled {
                let script = NetworkService.buildDisableScript(services: services)
                    + "\n" + LaunchDaemonManager.installCommands()
                try PrivilegedExecutor.execute(script)
            } else {
                let script = LaunchDaemonManager.removeCommands()
                    + "\n" + NetworkService.buildEnableScript(services: services)
                try PrivilegedExecutor.execute(script)
            }
        } catch PrivilegedExecutionError.userCancelled {
        } catch {
            errorMessage = error.localizedDescription
        }

        refreshState()
        isProcessing = false
    }

    private func refreshState() {
        isNetworkEnabled = !LaunchDaemonManager.isDaemonInstalled()
    }
}
