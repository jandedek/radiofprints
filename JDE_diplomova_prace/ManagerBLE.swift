
import Foundation
import CoreBluetooth



/// Třída zajišťuje management BlueTooth zařízení, jejich vyhledávání, připojování a odpojování
/// Pomocí delegátů informuje třídy které delegáty zachytávají o změnách stavu jedotlivých BT zařízení a o obdržené hodnotě RSSI.
class ManagerBLE: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    
    
    // MARK: - PROMĚNNÉ
    
    weak var delegate: WirelessManagerDelegate? // delegát s weak referencí
    private var centralManager: CBCentralManager? // manager který přijímá data
    private var peripheralsList: [CBPeripheral] = [CBPeripheral]() // pole pro ukládání strong referencí nalezených zařízení
    
    
    
    
    // MARK: - FUNKCE
    
    /// Spustí sběr dat
    public func start() {
        
        if ((centralManager != nil) && (centralManager?.isScanning)!) { stop() } // zastavit probíhající spojení
        peripheralsList.removeAll() // vyčištění referencí na peripherals nalezené v předchozím vyhledávání
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /// Zastaví sběr dat
    public func stop() {

        if (centralManager != nil) {
            for peripheral in peripheralsList {
                centralManager?.cancelPeripheralConnection(peripheral)
            }
            centralManager?.stopScan()
        }
        peripheralsList.removeAll()
    }
    
    /// Zkusí získat MAC adres BLE zařízení. Pokud jí není možné získat, vrátí nil
    private func getMacAddress(advertisementData: [String : Any]) -> String? {
        
        if let data = advertisementData["kCBAdvDataServiceData"] as? NSDictionary {
            
            for dataItem in data {
                
                let strKey: String? = String(describing: dataItem.key)
                let strValue: String? = String(describing: dataItem.value)
                
                if strKey != nil && strValue != nil && strKey!.compare("Device Information") == ComparisonResult.orderedSame && strValue!.characters.count > 15 {
                    
                    var macAddress = ""
                    var strArray = Array(strValue!.characters)

                    macAddress.append(strArray[12])
                    macAddress.append(strArray[13])
                    macAddress.append(":")
                    macAddress.append(strArray[10])
                    macAddress.append(strArray[11])
                    macAddress.append(":")
                    macAddress.append(strArray[7])
                    macAddress.append(strArray[8])
                    macAddress.append(":")
                    macAddress.append(strArray[5])
                    macAddress.append(strArray[6])
                    macAddress.append(":")
                    macAddress.append(strArray[3])
                    macAddress.append(strArray[4])
                    macAddress.append(":")
                    macAddress.append(strArray[1])
                    macAddress.append(strArray[2])
                    
                    return macAddress
                }
            }
        }
        
        return nil
    }
    

    
    // MARK: - DELEGÁTI CENTRAL MANAGERU + PERIPHERAL

    /// Delegát obdržený při změně stavu BT zařízení
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if  central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    /// Delegát obržený při nalezení BT zařízení v okolí
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        
        if let macAddress = getMacAddress(advertisementData: advertisementData) {
           
            if (!peripheralsList.contains(peripheral)) { peripheralsList.append(peripheral) } // uložení strong reference do pole, aby nedošlo k odpojení z důvodu odstranění GC
            
            let deviceName: String = peripheral.name ?? "Neznámé zařízení"
            let newDevice = DataItemBLE(uuid: peripheral.identifier, address: macAddress, deviceName: deviceName)
            delegate?.deviceDidConnect(newDevice: newDevice)

            peripheral.delegate = self
            central.connect(peripheral, options:nil) // pokus o přípojení se k zařízení
        }

    }
    
    /// Delegát obdržený při úspěšném navázání spojení s BT zařízením
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
      /*
        var deviceName: String = "Neznámé zařízení"
        if (peripheral.name != nil) { deviceName = peripheral.name! }
        
        let newDevice = DataItemBLE(uuid: peripheral.identifier)
        newDevice.deviceName = deviceName
        */
        //delegate?.deviceDidConnect(newDevice: newDevice)
        peripheral.readRSSI()
    }
    
    /// Delegát obdržený při odpojení od BT zařízení
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        central.connect(peripheral, options:nil) // pokus o znovupřípojení se k zařízení
    }
    
    /// Delegát obdržený při získání hodnoty RSSI (síla signálu)
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
 
        delegate?.bleDataReceived(uuid: peripheral.identifier, rssi: RSSI.intValue)
        peripheral.readRSSI()
    }
    
    
}
