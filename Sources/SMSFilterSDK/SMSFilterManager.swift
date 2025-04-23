import IdentityLookup

public class SMSFilterManager {
    @MainActor public static let shared = SMSFilterManager()
    private let rules = Rules.example

    private init() {}

    public func classify(
      query: ILMessageFilterQueryRequest
    ) -> (action: ILMessageFilterAction, subAction: ILMessageFilterSubAction) {
        let sender = (query.sender ?? "").lowercased()
        let body   = (query.messageBody ?? "").lowercased()
        let r      = rules

        print("🛠 classify() called – sender: \(sender), body: \(body)")

        // 1. Promocje
        if let m = r.promoKeywords.first(where: { body.contains($0.lowercased()) }) {
            print("🟡 matched promoKeywords: \(m)")
            return (.filter, .promotionalOffers)
        }
        // 2. Spam lub zablokowani nadawcy
        if r.blockedSenders.contains(where: { sender.contains($0.lowercased()) })
         || r.spamKeywords.contains(where: { body.contains($0.lowercased()) }) {
            print("🔴 matched spam/blocked")
            return (.filter, .none)
        }
        // 3. Pozostałe
        print("✅ no match → allow")
        return (.allow, .none)
    }
}
