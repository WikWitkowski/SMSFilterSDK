import Foundation
import IdentityLookup

/// Klasa dokonująca klasyfikacji wiadomości SMS/MMS na podstawie lokalnych reguł.
public class LocalRulesClassifier {
    private let database: LocalRulesDatabase

    public init(database: LocalRulesDatabase) {
        self.database = database
    }

    /// Analizuje nadawcę oraz treść wiadomości i zwraca odpowiednią akcję filtrowania.
    public func classifyMessage(sender: String?, message: String?) -> ILMessageFilterAction {
        // Jeżeli brak treści wiadomości, nie filtrujemy (pozwalamy na wiadomość).
        guard let messageBody = message?.lowercased() else {
            return .allow
        }
        // Pobieramy aktualne reguły z lokalnej bazy.
        let rules = database.loadRules()

        // 1. Sprawdź czy nadawca jest na czarnej liście (zablokowany).
        if let sender = sender?.lowercased(), rules.blockedSenders.map({ $0.lowercased() }).contains(sender) {
            return ILMessageFilterAction.junk  // nadawca zablokowany - odfiltrować wiadomość
        }
        // 2. Sprawdź czy treść zawiera którekolwiek słowo kluczowe spamu.
        for keyword in rules.spamKeywords {
            if keyword.isEmpty { continue }
            if messageBody.contains(keyword.lowercased()) {
                return ILMessageFilterAction.junk  // znaleziono podejrzane słowo - filtruj jako spam
            }
        }
        // 3. (Możliwe rozszerzenie) Sprawdź słowa kluczowe promocji/transakcji i ewentualnie zwróć inny typ akcji.
        // W tej uproszczonej implementacji pomijamy osobne traktowanie 'promo' i 'transaction' - wszystkie niechciane wiadomości filtrujemy jednakowo.

        // 4. Jeśli żadna reguła nie pasuje, nie filtruj (wiadomość dozwolona).
        return .allow
    }
}

