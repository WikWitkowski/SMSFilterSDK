import Foundation
import IdentityLookup

public class SMSFilterManager {
    @MainActor public static let shared = SMSFilterManager()

    private let rules: Rules

    private init() {
        // Pobieramy wbudowane reguły
        self.rules = Rules.example
    }

   public func classify(
  query: ILMessageFilterQueryRequest
) -> (action: ILMessageFilterAction, subAction: ILMessageFilterSubAction) {
    let sender = (query.sender ?? "").lowercased()
    let body   = (query.messageBody ?? "").lowercased()
    let r      = Rules.example  // lub inna Twoja reguła

    // 1. Promocje → filter + promotionalOffers
    if r.promoKeywords.contains(where: { body.contains($0.lowercased()) }) {
        return (.filter, .promotionalOffers)
    }
    // 2. Spam (blockedSender albo spamKeywords) → filter + none
    if r.blockedSenders.contains(where: { sender.contains($0.lowercased()) })
     || r.spamKeywords.contains(where: { body.contains($0.lowercased()) }) {
        return (.filter, .none)
    }
    // 3. Pozostałe → allow
    return (.allow, .none)
}
}

