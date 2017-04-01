
import UIKit
import CoreLocation



/// Třída obsahuje informace o naměřených GPS hodnotách
/// Je implementován ProtocolWirelessManager
class DataItemGPS: NSObject, ProtocolWirelessManager {

    
    
    // MARK: - PROMĚNNÉ
    
    /// interní náhodně vygenerované UUID (slouží pouze pro identifikaci v poli)
    public var uuid: UUID
    
    /// Indikuje zda je UUID skryté v přehledu při měření
    public let uuidIsHidden: Bool = true
    
    /// Seznam naměřených hodnot
    /// value: naměřené součadnice
    /// elapsedTime: času uplynulý od začátku měření v ms
    public var listOfValues:[(coordinates: CLLocationCoordinate2D, elapsedTime: Int)] = []
    
    
    
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
        
        if let lastValue = listOfValues.last {
            return "Lat: \(lastValue.coordinates.latitude) / Long: \(lastValue.coordinates.longitude)"
        }
        else {
            return ""
        }
    }
    
    /// Vrátí statický popis zařízení
    func stringDeviceName() -> String {
        
        return "Aktuální poloha"
    }

}
