import Observation
import ServiceManagement

@Observable
@MainActor
final class NetworkViewModel {
    var isNetworkEnabled: Bool = true
    var isProcessing: Bool = false
    var errorMessage: String?
    var launchAtLogin: Bool = false

    init() {
        refreshState()
        launchAtLogin = SMAppService.mainApp.status == .enabled
        enableLaunchAtLoginIfFirstLaunch()
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

    func toggleLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    private func refreshState() {
        isNetworkEnabled = !LaunchDaemonManager.isDaemonInstalled()
    }

    private func enableLaunchAtLoginIfFirstLaunch() {
        let key = "hasLaunchedBefore"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)
        try? SMAppService.mainApp.register()
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }
}
