import Foundation

extension URL {
    var tinLinkAppURI: URL {
        if let scheme = scheme, scheme != "http", scheme != "https", absoluteString.hasPrefix("\(scheme)://"), !absoluteString.hasPrefix("\(scheme):///") {
            let appUri = absoluteString.replacingOccurrences(of: "\(scheme)://", with: "\(scheme):///")
            guard let appURI = URL(string: appUri) else { fatalError("Invalid URL") }
            return appURI
        } else {
            return self
        }
    }
}
