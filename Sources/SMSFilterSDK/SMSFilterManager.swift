import Foundation
import IdentityLookup

/// Główna klasa zarządzająca logiką filtrowania SMS w SDK.
public class SMSFilterManager {
    @MainActor public static let shared = SMSFilterManager()

    private let classifier: LocalRulesClassifier

    let bundleID = Bundle.main.bundleIdentifier!           // np. "com.twojafirma.MyApp"
                  // "group.com.twojafirma.MyApp"
  

    private init() {
        // Inicjalizacja lokalnej bazy reguł z identyfikatorem App Group (zmień identyfikator na własny!)
        let appGroupID = "group.\(bundleID)"  // Uwaga: podmień na rzeczywisty identyfikator Twojej App Group
        let database = LocalRulesDatabase(appGroupIdentifier: appGroupID)
        self.classifier = LocalRulesClassifier(database: database)
    }

  public func classify(
        query: ILMessageFilterQueryRequest
    ) -> (action: ILMessageFilterAction, subAction: ILMessageFilterSubAction) {
        let action = classifier.classifyMessage(
            sender: query.sender,
            message: query.messageBody
        )

        // domyślnie brak subAction
        var sub: ILMessageFilterSubAction = .none

        // jeżeli to filtrowanie (spam), spróbuj wybrać kategorię
        if action == .filter {
            let body = (query.messageBody ?? "").lowercased()
            let rules = LocalRulesDatabase(appGroupIdentifier: classifier.database.appGroupIdentifier).loadRules()

            // np. najpierw promocje
            if rules.promoKeywords.contains(where: { body.contains($0.lowercased()) }) {
                sub = .promotionalOffers
            }
            // albo transakcje
            else if rules.transactionKeywords.contains(where: { body.contains($0.lowercased()) }) {
                sub = .transactionalFinance
            }
            // w przeciwnym razie pozostaje `.none` i trafi do Junk
        }

        return (action, sub)
    }
}
