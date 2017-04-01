
import UIKit



/// Třída obsahuje informace o mobilní síti
/// Je implementován ProtocolWirelessManager
class DataItemBTS: NSObject, ProtocolWirelessManager {


    
    // MARK: - PROMĚNNÉ
    
    /// interní náhodně vygenerované UUID (slouží pouze pro identifikaci v poli)
    public var uuid: UUID
    
    /// Indikuje zda je UUID skryté v přehledu při měření
    public let uuidIsHidden: Bool = true
    
    /// Podporovaná technologie
    public var currentRadioAccessTechnology: String = ""
    
    /// Indikuje zda provozovatel sítě podporuje VOIP
    public var allowsVOIP: Bool = false
    
    /// Jméno poskytovatele domovské sítě uživatele (nemění se při roamingu)
    public var carrierName: String = ""
    
    /// ISO kód země provozovatele sítě
    public var isoCountryCode: String = ""
    
    /// MCC provozovatele sítě
    public var mobileCountryCode: String = ""
    
    /// MNC provozovatele sítě
    public var mobileNetworkCode: String = ""
    
    
    
    /// Konstruktor třídy
    init(uuid: UUID) {
        
        self.uuid = uuid
        super.init()
    }
 
    
    
    // MARK: - FUNKCE
    
    /// Vrátí poslední naměřenou hodnotu v poli jako string
    /// Pokud nejsou žádné hodnoty k dispozici, vrátí se prázdný řetězec
    ///
    /// - Returns: Poslední hodnota převedená na textový řetězec
    func stringValue() -> String {
        
        return "Technology: \(currentRadioAccessTechnology) / Allows VOIP: \(allowsVOIP) / ISO: \(isoCountryCode) / MCC: \(mobileCountryCode) / MNC: \(mobileNetworkCode)"
    }
    
    /// Vrátí statický popis zařízení
    func stringDeviceName() -> String {
        
        return carrierName
    }
    
}
