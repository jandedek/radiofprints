
import UIKit
import CoreMotion
import CoreLocation



/// Controller obsluhuje view pro sběr dat - měření na místě (náhled na získané hodnoty v průběhu měření)
class DataCollectionViewController05b: UITableViewController, WirelessManagerDelegate {

    
    
    // MARK: - PROMĚNNÉ
    
    public var mapID: String = "" // identifikátor mapy předaná z mapView
    public var mapCoord: CGPoint? // souřadnice vybrané na mapě předané z mapView
    private let bleManager = ManagerBLE() // vytvoření nové instance bluetooth managera
    private let gpsManager = ManagerGPS() // vytvoření nové instance GPS managera
    private let btsManager = ManagerBTS() // vytvoření nové instance BTS managera
    private let wifiManager = ManagerWIFI() // vytvoření nové instance WiFi managera
    private let motionManager = CMMotionManager()
    private let dataHolder = DataHolder()
    private var remainingTime = SettingsManager.sharedInstance.countDown // délka měření v sekundách
    private var startTime: Date? // čas začátku měření
    
    
    
    // MARK: - UDÁLOSTI
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        bleManager.delegate = self
        gpsManager.delegate = self
        btsManager.delegate = self
        wifiManager.delegate = self
    
        motionManager.startGyroUpdates()
        motionManager.startMagnetometerUpdates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true //schování tab baru
        self.navigationItem.setHidesBackButton(true, animated:true) // skrytí tlačítka zpět
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        startTime = Date()
        dataHolder.level = mapID
        dataHolder.mapX = Int(mapCoord?.x ?? 0)
        dataHolder.mapY = Int(mapCoord?.y ?? 0)
        dataHolder.collectStartTime = startTime
        
        remainingTime = SettingsManager.sharedInstance.countDown // délka měření v sekundách
        self.title = String(format: "Probíhá měření: %i", remainingTime)

        if (SettingsManager.sharedInstance.useBluetooth) {bleManager.start()}
        if (SettingsManager.sharedInstance.useGPS) {gpsManager.start()}
        if (SettingsManager.sharedInstance.useWiFi) {wifiManager.start()}
        if (SettingsManager.sharedInstance.useBTS) {btsManager.start()}
        
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerTick), userInfo: nil, repeats: true)
    }
    
    /// Funkce volaná timerem při každém ticku
    ///
    /// - Parameter timer: objekt který funkci zavolal
    func timerTick(timer: Timer) {
        
        remainingTime -= 1
        
        self.title = String(format: "Probíhá měření - zbývá: \(remainingTime) s")
        
        if remainingTime == 0 {
            timer.invalidate()
            gatheringFinished()
        }
    }

    
        
    // MARK: - DELEGÁTI WIRELESS MANAGERŮ
    
    /// Připojení k BLE zařízení navázáno
    ///
    /// - Parameter newDevice: připojené zařízení
    func deviceDidConnect(newDevice: ProtocolWirelessManager) {
        
        if dataHolder.addDevice(newDevice: newDevice) { self.tableView.reloadData()}
    }
    
    /// Obdržení nově naměřené hodnoty z BLE zařízení
    ///
    /// - Parameters:
    ///   - uuid: unikátní identifikátor zařízení
    ///   - rssi: síla signálu
    func bleDataReceived (uuid:UUID, rssi: Int) {

        objc_sync_enter(startTime)
        let elapsedTime:Int = (Int)((startTime?.timeIntervalSinceNow)! * (-1000)) // čas od začátku měření v millisekundách
        objc_sync_exit(startTime)
        
        dataHolder.addValueBle(uuid: uuid, rssi: rssi, elapsedTime: elapsedTime)
        self.tableView.reloadData()
    }
    
    /// Obdržení nové naměřené hodnoty z GPS
    ///
    /// - Parameters:
    ///   - uuid: unikátní identifikátor zařízení
    ///   - coordinates: zeměpisné souřadnice
    func gpsDataReceived(uuid: UUID, coordinates: CLLocationCoordinate2D) {
    
        objc_sync_enter(startTime)
        let elapsedTime:Int = (Int)((startTime?.timeIntervalSinceNow)! * (-1000)) // čas od začátku měření v millisekundách
        objc_sync_exit(startTime)
        
        dataHolder.addValueGPS(uuid: uuid, coordinates: coordinates, elapsedTime: elapsedTime)
        self.tableView.reloadData()
    }
 

    
    // MARK: - FUNKCE
    
    /// Funkce ukončí sběr dat a zajistí jejich uložení do databáze
    func gatheringFinished() {
        
        self.title = "Ukládání dat"
        bleManager.stop()
        gpsManager.stop()
    
        dataHolder.collectEndTime = Date()
        dataHolder.createdAt = Date()
        
        // získání dat z gyroskopu
        if let gyroData = motionManager.gyroData {
            dataHolder.gyroX = gyroData.rotationRate.x
            dataHolder.gyroY = gyroData.rotationRate.y
            dataHolder.gyroZ = gyroData.rotationRate.z
        }
        
        // získání dat z magnetometru
        if let magnetoData = motionManager.magnetometerData {
            dataHolder.magnetoX = magnetoData.magneticField.x
            dataHolder.magnetoY = magnetoData.magneticField.y
            dataHolder.magnetoZ = magnetoData.magneticField.z
        }
        
        motionManager.stopGyroUpdates()
        motionManager.stopMagnetometerUpdates()
        
        saveDataToDatabase() // uložení naměřených dat do lokální databáze
        //self.performSegue(withIdentifier: "segueCollectingBackToRootNavigationController", sender: self)

        
        if let viewIndex = navigationController?.viewControllers.index(of: self) {
            if viewIndex > 0 {
                if let previousView = navigationController?.viewControllers[viewIndex - 1] as? DataCollectionViewController04b {
                    previousView.currentCoords = mapCoord
                }
            }
        }

        navigationController?.popViewController(animated: true)
    }
    
    /// Uložení dat do databáze
    func saveDataToDatabase() {

        if let database = try? CBLManager.sharedInstance().databaseNamed(SettingsManager.sharedInstance.localDbName) {
            let document = database.createDocument()
             _ = try? document.putProperties(dataHolder.exportToJson())
        }
    }

    
    
    // MARK: - DELEGÁTI TABLE VIEW

    /// Delegát pro nastavení počtu sekcí tabulky
    ///
    /// - Parameter tableView: tableview který delegáta vyvolal
    /// - Returns: počet sekcí
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    /// Delegát pro určení počtu řádků tabulky v jednotlivých sekcích
    ///
    /// - Parameters:
    ///   - tableView: tableview který delegáta vyvolal
    ///   - section: ID sekce
    /// - Returns: počet řádků v sekci
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataHolder.collectedData.count
    }

    /// Delegát pro nastavení obsahu jednotlivých řádků
    ///
    /// - Parameters:
    ///   - tableView: tableview který delegáta vyvolal
    ///   - indexPath: identifikátor řádku (obsahuje ID sekce a řádku v rámci sekce)
    /// - Returns: Vyplněná buňka tabulky
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        
        //použití připraveného prototypu buňky
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrototypeCellGathering", for: indexPath) as! PrototypeCellGathering
        let rowData = dataHolder.collectedData[indexPath.row]
        cell.showData(rowData: rowData)

        return cell
    }
    
}
