import SwiftGRPC

extension ProcessInfo {
    var tinkClientKey: String? {
        return environment["TINK_CLIENT_KEY"]
    }

    var tinkDeviceID: String? {
        return environment["TINK_DEVICE_ID"]
    }

    var tinkSessionID: String? {
        return environment["TINK_SESSION_ID"]
    }
}

extension Metadata {
    func addTinkMetadata() throws {
        let info = ProcessInfo.processInfo
        if let clientKey = info.tinkClientKey {
            try add(key: "X-Tink-Client-Key".lowercased(), value: clientKey)
        }
        if let deviceID = info.tinkDeviceID {
            try add(key: "X-Tink-Device-Id".lowercased(), value: deviceID)
        }
        if let sessionID = info.tinkSessionID {
            try add(key: "Authorization".lowercased(), value: "Session \(sessionID)")
        }
    }
}
