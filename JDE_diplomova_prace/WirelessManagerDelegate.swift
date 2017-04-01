
import UIKit
import CoreLocation



/// Delegát použitý při měření (informuje o přijetí nových dat)
protocol WirelessManagerDelegate: class
{
    
    
    
    /// Delegát volaný při připojení zařízení
    ///
    /// - Parameters:
    ///   - newDevice: připojené zařízení
    func deviceDidConnect(newDevice: ProtocolWirelessManager)
    
    /// Získaná nová hodnota BLE zařízení
    ///
    /// - Parameters:
    ///   - UUID: unikátní identifikátor zařízení
    ///   - RSSI: hodnota RSSI (síla signálu)
    func bleDataReceived (uuid: UUID, rssi: Int)
    
    /// Získané nové GPS souřadnice
    ///
    /// - Parameter coordinates: získaná poloha
    func gpsDataReceived(uuid: UUID, coordinates: CLLocationCoordinate2D)

}
