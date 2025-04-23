import Foundation
import IdentityLookup



public class SMSFilterManager {
    @MainActor public static let shared = SMSFilterManager()
    private let rules = Rules.example

    private init() {}

    /// Zwraca parę (action, subAction) i drukuje debugowo, jaki warunek został dopasowany
    public func classify(
        query: ILMessageFilterQueryRequest
    ) -> (action: ILMessageFilterAction, subAction: ILMessageFilterSubAction) {
        let sender = (query.sender ?? "").lowercased()
        let body   = (query.messageBody ?? "").lowercased()
        let r      = rules

        print("🛠 [Mgr] classify() called")
        print("    sender: \(sender)")
        print("    body:   \(body)")

        // 1. Promocje
        if let m = r.promoKeywords.first(where: { body.contains($0.lowercased()) }) {
            print("🟡 [Mgr] matched promoKeywords: \(m)")
            return (.filter, .promotionalOffers)
        }

        // 2. Zablokowani nadawcy
        if r.blockedSenders.contains(where: { sender.contains($0.lowercased()) }) {
            let matches = r.blockedSenders.filter { sender.contains($0.lowercased()) }
            print("🔴 [Mgr] matched blockedSenders: \(matches)")
            return (.filter, .none)
        }

        // 3. Spam keywords
        if let m = r.spamKeywords.first(where: { body.contains($0.lowercased()) }) {
            print("🔴 [Mgr] matched spamKeywords: \(m)")
            return (.filter, .none)
        }

        // 4. Pozostałe
        print("✅ [Mgr] no match → allow")
        return (.allow, .none)
    }
}

