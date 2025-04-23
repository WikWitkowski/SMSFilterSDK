import Foundation


/// Struktura przechowująca zestawy reguł filtrowania SMS.
public struct Rules: Decodable {
    public var blockedSenders: [String]
    public var spamKeywords: [String]
    public var promoKeywords: [String]
    public var transactionKeywords: [String]

    public init(blockedSenders: [String] = [],
                spamKeywords: [String] = [],
                promoKeywords: [String] = [],
                transactionKeywords: [String] = []) {
        self.blockedSenders = blockedSenders
        self.spamKeywords = spamKeywords
        self.promoKeywords = promoKeywords
        self.transactionKeywords = transactionKeywords
    }

    /// Wbudowany zestaw przykładowych reguł
    public static var example: Rules {
        return Rules(
            blockedSenders: [
                "+48111222333", "SpamFirm", "800123456", "+447700900123", "LOTTOBOT"
            ],
            spamKeywords: [
                "wygrałeś", "darmowy", "pilne", "konkurs", "bitcoin",
                "zyskaj", "okazja", "kliknij", "prezent", "voucher"
            ],
            promoKeywords: [
                "promocja", "zniżka", "sale", "black friday",
                "kod rabatowy", "wyprzedaż", "kupon", "mega promocja"
            ],
            transactionKeywords: [
                "kod weryfikacyjny", "potwierdzenie", "transakcja",
                "saldo", "rachunek", "faktura", "płatność"
            ]
        )
    }
}
