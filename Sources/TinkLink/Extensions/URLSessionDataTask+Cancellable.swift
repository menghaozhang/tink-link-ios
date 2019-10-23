import Foundation

extension URLSessionDataTask: RetryCancellable {
    public func retry() {
        resume()
    }
}
