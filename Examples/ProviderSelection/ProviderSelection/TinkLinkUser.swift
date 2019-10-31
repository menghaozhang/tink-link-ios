import Foundation
import TinkLink

class TinkLinkUser {
    private init() {}
    static let shared = TinkLinkUser()

    var user: User?
}
