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

    /// Przetwarza zapytanie filtrowania i zwraca decyzję (allow lub filter) dla danej wiadomości.
    public func filterMessage(query: ILMessageFilterQueryRequest) -> ILMessageFilterAction {
        return classifier.classifyMessage(sender: query.sender, message: query.messageBody)
    }
}
