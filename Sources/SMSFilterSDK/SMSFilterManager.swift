import Foundation
import IdentityLookup

public class SMSFilterManager {
    @MainActor public static let shared = SMSFilterManager()

    private let classifier: LocalRulesClassifier
    private let appGroupID: String

    private init() {
        let bundleID   = Bundle.main.bundleIdentifier ?? ""
        self.appGroupID = "group.\(bundleID)"
        let database   = LocalRulesDatabase(appGroupIdentifier: appGroupID)
        self.classifier = LocalRulesClassifier(database: database)
    }

    /// Zwraca (.filter/.allow, subAction) – teraz Promocje/Transakcje są brane pod uwagę jako filter
    public func classify(
      query: ILMessageFilterQueryRequest
    ) -> (action: ILMessageFilterAction, subAction: ILMessageFilterSubAction) {
        let bodyLower   = (query.messageBody ?? "").lowercased()
        let senderLower = (query.sender ?? "").lowercased()
        let rules       = LocalRulesDatabase(appGroupIdentifier: appGroupID).loadRules()

        // 1. blockedSenders → zawsze filter (junk)
        if rules.blockedSenders.contains(where: { senderLower.contains($0.lowercased()) }) {
            return (.filter, .none)
        }
        // 2. promoKeywords → filter + subAction promocyjny
        if rules.promoKeywords.contains(where: { bodyLower.contains($0.lowercased()) }) {
            return (.filter, .promotionalOffers)
        }
        // 3. transactionKeywords → filter + subAction transakcyjny
        if rules.transactionKeywords.contains(where: { bodyLower.contains($0.lowercased()) }) {
            return (.filter, .transactionalFinance)
        }
        // 4. spamKeywords → filter (junk)
        if rules.spamKeywords.contains(where: { bodyLower.contains($0.lowercased()) }) {
            return (.filter, .none)
        }
        // 5. w przeciwnym razie allow
        return (.allow, .none)
    }
}
