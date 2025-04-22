import Foundation
import IdentityLookup

public class SMSFilterManager {
    @MainActor public static let shared = SMSFilterManager()

    private let classifier: LocalRulesClassifier
    private let appGroupID: String

    private init() {
        // 1. Wyliczamy App Group ID na podstawie Bundle ID
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        self.appGroupID = "group.\(bundleID)"

        // 2. Inicjalizujemy bazę i classifier
        let database = LocalRulesDatabase(appGroupIdentifier: appGroupID)
        self.classifier = LocalRulesClassifier(database: database)
    }

    /// Zwraca parę (akcja, subAction) na podstawie zapytania filtrowania
    public func classify(
        query: ILMessageFilterQueryRequest
    ) -> (action: ILMessageFilterAction, subAction: ILMessageFilterSubAction) {
        // 1. Najpierw podstawowa klasyfikacja (.allow lub .filter)
        let action = classifier.classifyMessage(
            sender: query.sender,
            message: query.messageBody
        )

        // 2. Domyślny subAction
        var sub: ILMessageFilterSubAction = .none

        // 3. Jeżeli wiadomość jest filtrowana jako spam, dobieramy kategorię
        if action == .filter {
            let body = (query.messageBody ?? "").lowercased()
            // Wczytujemy reguły z tej samej App Group
            let rules = LocalRulesDatabase(appGroupIdentifier: appGroupID).loadRules()

            // 3a. Najpierw promocje
            if rules.promoKeywords.contains(where: { body.contains($0.lowercased()) }) {
                sub = .promotionalOffers
            }
            // 3b. Następnie transakcje
            else if rules.transactionKeywords.contains(where: { body.contains($0.lowercased()) }) {
                sub = .transactionalFinance
            }
            // 3c. W przeciwnym razie sub pozostaje .none (trafi do Junk)
        }

        return (action, sub)
    }
}
