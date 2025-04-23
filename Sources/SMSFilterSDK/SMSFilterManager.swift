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
        let r      = rules

        if r.blockedSenders.contains(where: { sender.contains($0.lowercased()) }) {
            return (.filter, .none)
        }
        if r.promoKeywords.contains(where: { body.contains($0.lowercased()) }) {
            return (.filter, .promotionalOffers)
        }
        if r.transactionKeywords.contains(where: { body.contains($0.lowercased()) }) {
            return (.filter, .transactionalFinance)
        }
        if r.spamKeywords.contains(where: { body.contains($0.lowercased()) }) {
            return (.filter, .none)
        }
        return (.allow, .none)
    }
}

