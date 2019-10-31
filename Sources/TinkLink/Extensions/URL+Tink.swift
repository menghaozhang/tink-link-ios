import Foundation

extension URL {
    var tinkLinkAppURI: URL {
        if let scheme = scheme, absoluteString == "\(scheme)://" {
            guard let appURI = URL(string: "\(scheme):///") else { fatalError("Invalid URL \(absoluteString)") }
            return appURI
        } else {
            return self
        }
    }
}
