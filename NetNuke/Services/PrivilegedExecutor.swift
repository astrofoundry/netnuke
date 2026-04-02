import Foundation

enum PrivilegedExecutionError: Error, Equatable {
    case userCancelled
    case scriptError(String)
}

enum PrivilegedExecutor {
    @MainActor
    static func execute(_ script: String) throws {
        let singleLine = script
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ; ")

        let escaped = singleLine
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let source = "do shell script \"\(escaped)\" with administrator privileges"

        var error: NSDictionary?
        let appleScript = NSAppleScript(source: source)
        appleScript?.executeAndReturnError(&error)

        if let error {
            let errorNumber = error[NSAppleScript.errorNumber] as? Int
            if errorNumber == -128 {
                throw PrivilegedExecutionError.userCancelled
            }
            let message = error[NSAppleScript.errorMessage] as? String ?? "Unknown error"
            throw PrivilegedExecutionError.scriptError(message)
        }
    }
}
