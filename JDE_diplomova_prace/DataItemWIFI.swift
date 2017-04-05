
import UIKit



/// Třída obsahuje informace o získaných datech z WiFi
/// Je implementován ProtocolWirelessManager
class DataItemWIFI: NSObject, ProtocolWirelessManager {

    
   
    // MARK: - PROMĚNNÉ
    
    /// interní náhodně vygenerované UUID (slouží pouze pro identifikaci v poli)
    public var uuid: UUID
    
    /// Indikuje zda je UUID skryté v přehledu při měření
    public let uuidIsHidden: Bool = true
    
    /// Název sítě
    public var SSID: String = ""
    
    /// MAC adresa přístupového bodu
    public var BSSID: String = ""
    
    
    
    /// Konstruktor třídy
    init(uuid: UUID) {
        
        self.uuid = uuid
        super.init()
    }
    

    
    // MARK: - FUNKCE
    
    /// Funkce vrátí naměřené hodnoty jako string
    ///
    /// - Returns: řetězec reprezentující naměřené hodnoty
    func stringValue() -> String {
        
        return "BSSID: \(BSSID)"
    }
    
    /// Vrátí název sítě
    ///
    /// - Returns: název sítě
    func stringDeviceName() -> String {
        
        return "SSID: \(SSID)"
    }

}
