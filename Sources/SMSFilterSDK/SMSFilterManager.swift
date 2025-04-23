import Foundation
import IdentityLookup

public class SMSFilterManager {
    @MainActor public static let shared = SMSFilterManager()
    private let rules = Rules.example

    private init() {}

    /// Zwraca parę (action, subAction):
    /// - .promotion / .promotionalOffers  → Promocje
    /// - .junk      / .none               → Niechciane (Spam)
    /// - .allow     / .none               → Pozwól
    public func classify(
      query: ILMessageFilterQueryRequest
    ) -> (action: ILMessageFilterAction, subAction: ILMessageFilterSubAction) {
        let sender = (query.sender ?? "").lowercased()
        let body   = (query.messageBody ?? "").lowercased()
        let r      = rules

        print("🛠 classify() called – sender: \(sender), body: \(body)")

        // 1) PROMOCJE
        if let match = r.promoKeywords.first(where: { body.contains($0.lowercased()) }) {
            print("🟡 matched promoKeywords: \(match)")
            return (.promotion, .promotionalOffers)
        }
        // 2) SPAM / BLOKOWANI NADAWCY
        if r.blockedSenders.contains(where: { sender.contains($0.lowercased()) }) {
            print("🔴 matched blockedSenders")
            return (.junk, .none)
        }
        if let match = r.spamKeywords.first(where: { body.contains($0.lowercased()) }) {
            print("🔴 matched spamKeywords: \(match)")
            return (.junk, .none)
        }
        // 3) POZOSTAŁE
        print("✅ no match → allow")
        return (.allow, .none)
    }
}
