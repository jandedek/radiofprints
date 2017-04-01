
import Foundation
import SystemConfiguration.CaptiveNetwork



/// Třída zajišťuje získání informací o právě připojené WiFi síti
class ManagerWIFI: NSObject {

    
    
    // MARK: - PROMĚNNÉ
    
    weak var delegate: WirelessManagerDelegate? // delegát s weak referencí
    
    /// interní náhodně vygenerované UUID (slouží pouze pro identifikaci v poli)
    public let uuid = UUID()
    
    
    
    // MARK: - FUNKCE
    
    /// Získání dat a jejich vrácení pomocí delegáta DeviceDidConnect
    public func start() {
        
        if let supportedInterfaces = CNCopySupportedInterfaces() {
            let count = CFArrayGetCount(supportedInterfaces) // počet hodnot v poli
            
            for i in 0...count-1 {
                let rawValue: UnsafeRawPointer = CFArrayGetValueAtIndex(supportedInterfaces, i)
                let castValue = unsafeBitCast(rawValue, to: AnyObject.self)
                if let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(castValue)" as CFString) {
                    let dictData = unsafeInterfaceData as! [String:AnyObject]
                    let newDevice = DataItemWIFI(uuid: uuid)
                    newDevice.BSSID = String(describing: dictData["BSSID"]!)
                    newDevice.SSID = String(describing: dictData["SSID"]!)
                    delegate?.deviceDidConnect(newDevice: newDevice)
                }
            }
        }
    }

}
