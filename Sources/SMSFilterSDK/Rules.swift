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
}
