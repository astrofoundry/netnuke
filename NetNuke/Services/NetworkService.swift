import Foundation

enum NetworkService {
    static func listServices() throws -> [String] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
        process.arguments = ["-listallnetworkservices"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        return output
            .components(separatedBy: "\n")
            .dropFirst()
            .map { $0.hasPrefix("*") ? String($0.dropFirst()) : $0 }
            .filter { !$0.isEmpty }
    }

    static func buildEnableScript(services: [String]) -> String {
        services.map { service in
            "networksetup -setnetworkserviceenabled \(shellEscaped(service)) on"
        }.joined(separator: "\n")
    }

    static func buildDisableScript(services: [String]) -> String {
        services.map { service in
            "networksetup -setnetworkserviceenabled \(shellEscaped(service)) off"
        }.joined(separator: "\n")
    }

    private static func shellEscaped(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}
