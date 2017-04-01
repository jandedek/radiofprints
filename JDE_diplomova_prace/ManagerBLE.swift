
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
    func stop() {

        if (centralManager != nil) {
            for peripheral in peripheralsList {
                centralManager?.cancelPeripheralConnection(peripheral)
            }
            centralManager?.stopScan()
        }
        peripheralsList.removeAll()
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
        
        if (!peripheralsList.contains(peripheral)) { peripheralsList.append(peripheral) } // uložení strong reference do pole, aby nedošlo k odpojení z důvodu odstranění GC
        peripheral.delegate = self
        central.connect(peripheral, options:nil) // pokus o přípojení se k zařízení
    }
    
    /// Delegát obdržený při úspěšném navázání spojení s BT zařízením
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        var deviceName: String = "Neznámé zařízení"
        if (peripheral.name != nil) { deviceName = peripheral.name! }
        
        let newDevice = DataItemBLE(uuid: peripheral.identifier)
        newDevice.deviceName = deviceName
        
        delegate?.deviceDidConnect(newDevice: newDevice)
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
