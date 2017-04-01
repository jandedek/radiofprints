
import Foundation
import CoreTelephony



/// Třída zajišťuje získání informací o mobilním připojení
class ManagerBTS: NSObject {


    
    // MARK: - PROMĚNNÉ
    
    weak var delegate: WirelessManagerDelegate? // delegát s weak referencí
    private var networkInfo: CTTelephonyNetworkInfo?

    /// interní náhodně vygenerované UUID (slouží pouze pro identifikaci v poli)
    public let uuid = UUID()
    
    
    
    // MARK: - FUNKCE
    
    /// Získání dat a jejich vrácení pomocí delegáta DeviceDidConnect
    public func start() {
        
        networkInfo = CTTelephonyNetworkInfo()
        
        if (networkInfo?.subscriberCellularProvider != nil) {
            let newDevice = DataItemBTS(uuid: uuid)
            if networkInfo?.currentRadioAccessTechnology != nil {newDevice.currentRadioAccessTechnology = networkInfo!.currentRadioAccessTechnology!}
            newDevice.allowsVOIP = networkInfo!.subscriberCellularProvider!.allowsVOIP
            if networkInfo?.subscriberCellularProvider?.carrierName != nil {newDevice.carrierName = networkInfo!.subscriberCellularProvider!.carrierName!}
            if networkInfo?.subscriberCellularProvider?.isoCountryCode != nil {newDevice.isoCountryCode = networkInfo!.subscriberCellularProvider!.isoCountryCode!}
            if networkInfo?.subscriberCellularProvider?.mobileCountryCode != nil {newDevice.mobileCountryCode = networkInfo!.subscriberCellularProvider!.mobileCountryCode!}
            if networkInfo?.subscriberCellularProvider?.mobileNetworkCode != nil {newDevice.mobileNetworkCode = networkInfo!.subscriberCellularProvider!.mobileNetworkCode!}
            
            delegate?.deviceDidConnect(newDevice: newDevice)
        }
    }
    
}
