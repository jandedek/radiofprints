
import UIKit



/// Protokol který implementují třídy pro uložení naměřenách dat
protocol ProtocolWirelessManager {
    

    
    // MARK: - PROMĚNNÉ
    
    /// Unikátní identifikátor zařízení
    var uuid: UUID {get}
    
    /// Informace zda se má hodnota UUID zobrazit v tabulce (false) nebo zda má být skryta (true)
    var uuidIsHidden: Bool {get}
    
    
    
    // MARK: - FUNKCE
    
    /// Funkce vrací hodnotu jako string
    ///
    /// - Returns: string hodnota
    func stringValue() -> String
    
    /// Název zařízení
    ///
    /// - Returns: název zařízení jako string
    func stringDeviceName() -> String

}
