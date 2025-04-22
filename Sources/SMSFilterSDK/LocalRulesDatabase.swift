import Foundation

/// Klasa odpowiadająca za przechowywanie i wczytywanie reguł z pamięci lokalnej (udostępnionej między appką a rozszerzeniem).
public class LocalRulesDatabase {
    private let suite: UserDefaults?

    /// Inicjalizuje bazę reguł z podanym identyfikatorem App Group.
    public init(appGroupIdentifier: String) {
        self.suite = UserDefaults(suiteName: appGroupIdentifier)
    }

    /// Wczytuje aktualne reguły z pamięci udostępnionej (App Group).
    public func loadRules() -> Rules {
        // Pobranie list z UserDefaults (jeśli brak danych, użyjemy pustych list)
        let blockedSenders = suite?.array(forKey: "BlockedSenders") as? [String] ?? []
        let spamKeywords = suite?.array(forKey: "SpamKeywords") as? [String] ?? []
        let promoKeywords = suite?.array(forKey: "PromoKeywords") as? [String] ?? []
        let transactionKeywords = suite?.array(forKey: "TransactionKeywords") as? [String] ?? []
        
        print("111! Załadowano Reguły")

        return Rules(blockedSenders: blockedSenders,
                     spamKeywords: spamKeywords,
                     promoKeywords: promoKeywords,
                     transactionKeywords: transactionKeywords)
        
      
    }

    /// Zapisuje podane reguły do pamięci udostępnionej (App Group).
    /// UWAGA: operację zapisu należy wykonywać **tylko** w kontekście aplikacji (rozszerzenie nie może zapisywać danych).
    public func saveRules(_ rules: Rules) {
        suite?.set(rules.blockedSenders, forKey: "BlockedSenders")
        suite?.set(rules.spamKeywords, forKey: "SpamKeywords")
        suite?.set(rules.promoKeywords, forKey: "PromoKeywords")
        suite?.set(rules.transactionKeywords, forKey: "TransactionKeywords")
        suite?.synchronize()
        
        print("111! Zapisano Reguły")
    }
    /// Pobiera JSON z zewnętrznego API i po sparsowaniu zapisuje go lokalnie.
     /// - Parameters:
     ///   - url: Endpoint zwracający JSON zgodny z kodowalnym modelem `Rules`.
     ///   - completion: Wywoływane na wątku głównym z wynikiem operacji lub błędem.
     public func fetchRules(
         from url: URL,
         completion: @escaping (Result<Rules, Error>) -> Void
     ) {
         let task = URLSession.shared.dataTask(with: url) { data, response, error in
             // 1) Błąd sieciowy
             if let error = error {
                 DispatchQueue.main.async {
                     completion(.failure(error))
                 }
                 return
             }
             // 2) Brak danych
             guard let data = data else {
                 let err = NSError(
                     domain: "LocalRulesDatabase",
                     code: -1,
                     userInfo: [NSLocalizedDescriptionKey: "Brak danych z serwera"]
                 )
                 DispatchQueue.main.async {
                     completion(.failure(err))
                 }
                 return
             }
             // 3) Parsowanie JSON do modelu Rules
             do {
                 let decoder = JSONDecoder()
                 let newRules = try decoder.decode(Rules.self, from: data)
                 // 4) Zapis do App Group
                 self.saveRules(newRules)
                 DispatchQueue.main.async {
                     completion(.success(newRules))
                 }
             } catch {
                 DispatchQueue.main.async {
                     completion(.failure(error))
                 }
             }
         }
         task.resume()
     }
 }

