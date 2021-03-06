
import UIKit



/// Třída obsahuje informace o naměřených BLE hodnotách
/// Je implementován ProtocolWirelessManager
class DataItemBLE: NSObject, ProtocolWirelessManager {

    
    
    // MARK: - PROMĚNNÉ
    
    /// UUID zařízení
    public var uuid: UUID
    
    /// Indikuje zda je UUID skryté v přehledu při měření
    public let uuidIsHidden: Bool = false
    
    /// Seznam naměřených hodnot
    /// RSSI: síla signálu
    /// elapsedTime: času uplynulý od začátku měření v ms
    public var listOfValues:[(rssi: Int, elapsedTime: Int)] = []
    
    /// Název zařízení
    public var deviceName: String = ""
    
    
    
    /// Konstruktor třídy
    init(uuid: UUID) {
        
        self.uuid = uuid
        super.init()
    }
    
    

    // MARK: - FUNKCE
    
    /// Vrací poslední naměřenou hodnotu v poli jako string
    /// Pokud nejsou žádné hodnoty k dispozici, vrátí se prázdný řetězec
    ///
    /// - Returns: Poslední hodnota převedená na textový řetězec
    func stringValue() -> String {
        
        if let lastValue = listOfValues.last {
            return "RSSI: \(lastValue.rssi) dB"
        }
        else {
            return ""
        }
    }
    
    /// Vrací název zařízení
    func stringDeviceName() -> String {
        
        return deviceName
    }
    
}
