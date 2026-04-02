import Foundation

enum LaunchDaemonManager {
    static let plistPath = "/Library/LaunchDaemons/com.netguard.killnet.plist"
    static let scriptPath = "/usr/local/bin/netguard-killnet.sh"

    static func isDaemonInstalled() -> Bool {
        FileManager.default.fileExists(atPath: plistPath)
    }

    static func installCommands() -> String {
        let killScript = """
            #!/bin/bash
            sleep 2
            while IFS= read -r service; do
                [[ -z "$service" ]] && continue
                service="${service#\\*}"
                networksetup -setnetworkserviceenabled "$service" off
            done < <(networksetup -listallnetworkservices | tail -n +2)
            """

        let plist = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>com.netguard.killnet</string>
                <key>ProgramArguments</key>
                <array>
                    <string>/bin/bash</string>
                    <string>\(scriptPath)</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
            </dict>
            </plist>
            """

        let killScriptB64 = Data(killScript.utf8).base64EncodedString()
        let plistB64 = Data(plist.utf8).base64EncodedString()

        return """
            mkdir -p /usr/local/bin
            echo '\(killScriptB64)' | base64 -d > \(scriptPath)
            chmod 755 \(scriptPath)
            chown root:wheel \(scriptPath)
            echo '\(plistB64)' | base64 -d > \(plistPath)
            chmod 644 \(plistPath)
            chown root:wheel \(plistPath)
            """
    }

    static func removeCommands() -> String {
        """
        launchctl bootout system/com.netguard.killnet 2>/dev/null || true
        rm -f '\(plistPath)'
        rm -f '\(scriptPath)'
        """
    }
}
