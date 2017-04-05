
import UIKit
import CoreLocation



/// Třída udržuje data z databáze a poskytuje k nim přístup přes vlastnosti a funkce.
/// Jeden couchbase dokument odpovídá jedné instanci této třídy.
/// Hodnoty zadané do instance této třídy je možné vyexportovat do formátu JSON pro uložení do couchbase databáze
/// Třída obsahuje staické funkce pomocí kterých je možné naimportovat couchbase dokument (vrátí se naplněná instance třídy) nebo celou databázi (vrátí se pole instancí této třídy)
class DataHolder: NSObject, Comparable {


    
    // MARK: - PROMĚNNÉ
    
    /// Indikuje stav nabití baterie v rozmezí 0 až 1.0
    public var batteryLevel: Float? = UIDevice.current.batteryLevel
    
    /// Indikuje režim v jakém se baterie nachází (unpluged/charging/full/unknown)
    public var batteryState: String? = ""
    
    /// ID zařízení
    public var deviceID: String? = UIDevice.current.identifierForVendor?.uuidString
    
    /// Model zařízení
    public var model: String? = UIDevice.current.model
    
    /// Název operačního systému
    public var systemName: String? = UIDevice.current.systemName
    
    /// Verze operačního systému
    public var systemVersion: String? = UIDevice.current.systemVersion
    
    /// Indikuje zda byl do měření zahrnuto bluetooth
    public var collectBluetoothData: Bool? = SettingsManager.sharedInstance.useBluetooth
    
    /// Indikuje zda bylo do měření zahrnuto GPS
    public var collectGpsData: Bool? = SettingsManager.sharedInstance.useGPS
    
    /// Indikuje zda byla do měření zahrnuta WiFi síť
    public var collectWifiData: Bool? = SettingsManager.sharedInstance.useWiFi
    
    /// Indikuje zda bylo do měření zahrnuto BTS
    public var collectBtsData: Bool? = SettingsManager.sharedInstance.useBTS
    
    /// Data z gyroskopu - osa X
    public var gyroX: Double? = 0
    
    /// Data z gyroskopu - osa Y
    public var gyroY: Double? = 0
    
    /// Data z gyroskopu - osa Z
    public var gyroZ: Double? = 0
    
    /// Data z magnetometru - osa X
    public var magnetoX: Double? = 0
    
    /// Data z magnetometru - osa Y
    public var magnetoY: Double? = 0
    
    /// Data z magnetometru - osa Z
    public var magnetoZ: Double? = 0
    
    /// Čas začátku měření
    public var collectStartTime: Date?
    
    /// Čas konce měření
    public var collectEndTime: Date?
    
    /// Čas vytvoření záznamu v databázi
    public var createdAt: Date?
    
    /// Identifikátor zvolené mapy
    public var level: String? = ""
    
    /// ID uživatele
    public var userID: String? = ""
    
    /// souřadnice X vybraná na mapě
    public var mapX: Int? = 0
    
    /// souřadnice Y vybraná na mapě
    public var mapY: Int? = 0
    
    /// naměřené hodnoty
    public var collectedData = [ProtocolWirelessManager]()
    
    /// dokument v databázi (databázová reprezentace dat této třídy).
    /// Tato vlastnost je vyplněna při importu dat z databáze.
    public var databaseDocument: CBLDocument?
    
    
    
    /// Konstuktor třídy
    override init() {
        
        switch UIDevice.current.batteryState.rawValue {
        case 1:
            batteryState = "unplugged"
        case 2:
            batteryState = "charging"
        case 3:
            batteryState = "full"
        default:
            batteryState = "unknown"
        }
    }
    
    
    
    // MARK: - FUNKCE
    
    /// Přidání nového zařízení do seznamu
    ///
    /// - Parameters:
    ///   - newDevice: nové zařízení
    /// - Returns: Pokud bylo zařízení přidáno vrátí TRUE, jinak FALSE
    func addDevice(newDevice: ProtocolWirelessManager) -> Bool {

        objc_sync_enter(self)
        
        // kontrola zda zařízení již není v seznamu
        for item in collectedData where item.uuid == newDevice.uuid {
            objc_sync_exit(self)
            return false
        }
        collectedData.append(newDevice) // zařízení nebylo nalezeno v poli - přidání do pole
        objc_sync_exit(self)
   
        return true
    }
    
    /// Přidá novou hodnotu do seznamu hodnot u BLE zařízení
    ///
    /// - Parameters:
    ///   - uuid: jednoznačný identifikátor zařízení
    ///   - rssi: přidávaná hodnota
    ///   - elapsedTime: počet milisekund od počátku měření
    func addValueBle(uuid: UUID, rssi: Int, elapsedTime: Int) {
        
        // nalezení zařízení podle UUID a přidání hodnoty RSSI
        objc_sync_enter(self)
 
        for item in collectedData where item.uuid == uuid {
            if let convertedItem = item as? DataItemBLE {
                let newValue = (rssi: rssi, elapsedTime: elapsedTime)
                convertedItem.listOfValues.append(newValue)
            }
        }
        objc_sync_exit(self)
    }
 
    /// Přidá novou hodnotu do seznamu hodnot u GPS
    ///
    /// - Parameters:
    ///   - uuid: jednoznačný identifikátor zařízení
    ///   - coordinates: nové souřadnice
    ///   - elapsedTime: počet milisekund od počátku měření
    func addValueGPS(uuid: UUID, coordinates: CLLocationCoordinate2D, elapsedTime: Int) {
    
        // nalezení zařízení podle UUID a přidání hodnoty RSSI
        objc_sync_enter(self)
        
        for item in collectedData where item.uuid == uuid {
            if let convertedItem = item as? DataItemGPS {
                let newValue = (coordinates: coordinates, elapsedTime: elapsedTime)
                convertedItem.listOfValues.append(newValue)
            }
        }
        objc_sync_exit(self)
    }
    
    /// Vygeneruje data ve formátu JSON (ve Swift reprezentované jako dictionary) pro uložení do databáze
    ///
    /// - Returns: JSON ve formátu pro uložení do databáze
    func exportToJson() -> [String : Any]{
        
        // nastavení formátu data a času
        let dateFormat = DateFormatter()
        dateFormat.dateFormat="yyyy-MM-dd HH:mm:ss"
        
        // *** vytvoření dictionary se základními daty ***
        var jsonData =
        [
            "batteryLevel": self.batteryLevel!.description,
            "batteryState": self.batteryState!,
            "deviceId": self.deviceID!,
            "hardware": self.model!,
            "osName": self.systemName!,
            "osId": self.systemVersion!,
            "collectBluetoothData": self.collectBluetoothData!.description,
            "collectGeolocationData": self.collectGpsData!.description,
            "collectWifiData": self.collectWifiData!.description,
            "collectBtsData": self.collectBtsData!.description,
            "gyroX": self.gyroX!.description,
            "gyroY": self.gyroY!.description,
            "gyroZ": self.gyroZ!.description,
            "magX": self.magnetoX!.description,
            "magY": self.magnetoY!.description,
            "magZ": self.magnetoZ!.description,
            "startTime": dateFormat.string(from: self.collectStartTime!),
            "endTime": dateFormat.string(from: self.collectEndTime!),
            "level": self.level!,
            "couchbase_sync_gateway_id": "-", // ID bude doplněno při synchronizace podle aktuálně přihlášeného uživatele
            "x": self.mapX!.description,
            "y": self.mapY!.description,
            "createdAt": dateFormat.string(from: self.createdAt!)
        ] as [String : Any]
        
        // *** přidání naměřených dat BLE ***
        if self.collectBluetoothData! {
            var bleData = [Any]()
            
            // procházení zařízení
            for case let device as DataItemBLE in self.collectedData {
                // procházení naměřených hodnot pro každé zařízení
                for collectedValues in device.listOfValues {
                    let deviceData =
                    [
                        "uuid": device.uuid.uuidString,
                        "address": device.address,
                        "rssi": collectedValues.rssi.description,
                        "time": collectedValues.elapsedTime.description,
                        "deviceName": device.stringDeviceName()
                    ] as [String : Any]
                    
                    bleData.append(deviceData)
                }
            }
            jsonData.updateValue(bleData, forKey: "bleScans")
        }
        
        // *** přidání naměřených dat WiFi ***
        if self.collectWifiData! {
            var wifiData = [Any]()
            for case let device as DataItemWIFI in self.collectedData {
                let deviceData =
                [
                    "ssid": device.SSID,
                    "mac": device.BSSID
                ] as [String : Any]
                wifiData.append(deviceData)
            }
            jsonData.updateValue(wifiData, forKey: "wifiScans")
        }
                
        // *** přidání naměřených dat BTS ***
        if self.collectBtsData! {
            var btsData = [Any]()
            for case let device as DataItemBTS in self.collectedData {
                let deviceData =
                [
                    "allowsVOIP": device.allowsVOIP.description,
                    "carrierName": device.carrierName,
                    "currentRadioAccessTechnology": device.currentRadioAccessTechnology,
                    "isoCountryCode": device.isoCountryCode,
                    "mobileCountryCode": device.mobileCountryCode,
                    "mobileNetworkCode": device.mobileNetworkCode
                ] as [String : Any]
                btsData.append(deviceData)
            }
            jsonData.updateValue(btsData, forKey: "cellScans")
        }
                
        // *** přidání geolokačních dat ***
        if self.collectGpsData! {
            var geolocationData = [Any]()
            // procházení zařízení
            for case let device as DataItemGPS in self.collectedData {
                // procházení naměřených hodnot pro každé zařízení
                for collectedValues in device.listOfValues {
                    let deviceData =
                    [
                        "lat": collectedValues.coordinates.latitude.description,
                        "long": collectedValues.coordinates.longitude.description,
                        "time": collectedValues.elapsedTime.description,
                    ] as [String : Any]
                    geolocationData.append(deviceData)
                }
            }
            jsonData.updateValue(geolocationData, forKey: "geolocation")
        }
        
        return jsonData
    }
    
    /// Vrátí naměřená data (jeden DataItemBTS). Pokud by bylo DataItemBTS v poli více, vrátí první item v pořadí.
    ///
    /// - Returns: DataItemBTS reprezentující naměřená data. Pokud měření mobilních dat nebylo prováděno, vrátí nil
    func getMobileData() -> DataItemBTS? {
        
        for case let device as DataItemBTS in self.collectedData {
            return device
        }

        return nil
    }
    
    /// Vrátí naměřená data (jeden DataItemWIFI). Pokud by bylo DataItemWIFI v poli více, vrátí první item v pořadí.
    ///
    /// - Returns: DataItemWIFI reprezentující naměřená data. Pokud měření wifi nebylo prováděno, vrátí nil
    func getWifiData() -> DataItemWIFI? {
        
        for case let device as DataItemWIFI in self.collectedData {
            return device
        }
        
        return nil
    }
    
    /// Vrátí naměřená data (jeden DataItemGPS). Pokud by bylo DataItemGPS v poli více, vrátí první item v pořadí.
    ///
    /// - Returns: DataItemGPS reprezentující naměřená data. Pokud měření GPS nebylo prováděno, vrátí nil
    func getGpsData() -> DataItemGPS? {
        
        for case let device as DataItemGPS in self.collectedData {
            return device
        }
        
        return nil
    }
    
    /// Vrátí pole naměřeních dat (pole DataItemBLE). Pokud není žádný item nalezen, vrátí se prázdné pole
    ///
    /// - Returns: Pole naplněné instancemi třídy DataItemBLE
    func getBleData() -> [DataItemBLE] {
        
        var result = [DataItemBLE]()
        
        for case let device as DataItemBLE in self.collectedData {
            result.append(device)
        }
        
        return result
    }
    
    /// Statická funkce příjme dokument (jeden záznam z databáze) a jeho hodnoty použije k naplnění property
    ///
    /// - Parameter document: vstupní data z databáze
    /// - Returns: Instance třídy naplněná daty z databáze
    static func importDocument(document: CBLDocument) -> DataHolder {
        
        let data = DataHolder()
        data.databaseDocument = document
 
        // nastavení očekávaného formátu data a času
        let dateFormat = DateFormatter()
        dateFormat.dateFormat="yyyy-MM-dd HH:mm:ss"

        if (document.property(forKey: "startTime") != nil) {data.collectStartTime = dateFormat.date(from: (document.property(forKey: "startTime") as! String))}
        if (document.property(forKey: "endTime") != nil) {data.collectEndTime = dateFormat.date(from: document.property(forKey: "endTime") as! String)}
        if (document.property(forKey: "createdAt") != nil) {data.createdAt = dateFormat.date(from: document.property(forKey: "createdAt") as! String)}
        data.batteryLevel = (document.property(forKey: "batteryLevel") as? NSString)?.floatValue
        data.self.batteryState = document.property(forKey: "batteryState") as? String
        data.deviceID = document.property(forKey: "deviceId") as? String
        data.model = document.property(forKey: "hardware") as? String
        data.systemName = document.property(forKey: "osName") as? String
        data.systemVersion = document.property(forKey: "osId") as? String
        data.collectBluetoothData = (document.property(forKey: "collectBluetoothData") as? NSString)?.boolValue
        data.collectGpsData = (document.property(forKey: "collectGeolocationData") as? NSString)?.boolValue
        data.collectWifiData = (document.property(forKey: "collectWifiData") as? NSString)?.boolValue
        data.collectBtsData = (document.property(forKey: "collectBtsData") as? NSString)?.boolValue
        data.gyroX = (document.property(forKey: "gyroX") as? NSString)?.doubleValue
        data.gyroY = (document.property(forKey: "gyroY") as? NSString)?.doubleValue
        data.gyroZ = (document.property(forKey: "gyroZ") as? NSString)?.doubleValue
        data.magnetoX = (document.property(forKey: "magX") as? NSString)?.doubleValue
        data.magnetoY = (document.property(forKey: "magY") as? NSString)?.doubleValue
        data.magnetoZ = (document.property(forKey: "magZ") as? NSString)?.doubleValue
        data.userID = document.property(forKey: "couchbase_sync_gateway_id") as? String
        data.level = document.property(forKey: "level") as? String
        data.mapX = (document.property(forKey: "x") as? NSString)?.integerValue
        data.mapY = (document.property(forKey: "y") as? NSString)?.integerValue
        
        // WIFI SCAN
        if let wifiScan = document.property(forKey: "wifiScans") as? NSArray {
            for item in wifiScan {
                if let device = item as? NSDictionary {
                    let dataItemWIFI = DataItemWIFI(uuid: UUID())
                    dataItemWIFI.BSSID = (device.value(forKey: "mac") as? String) ?? ""
                    dataItemWIFI.SSID = (device.value(forKey: "ssid") as? String) ?? ""
                    _ = data.addDevice(newDevice: dataItemWIFI) // přidání dat do pole
                }
            }
        }
        
        // CELLS SCAN
        if let cellsScan = document.property(forKey: "cellScans") as? NSArray {
            for item in cellsScan {
                if let device = item as? NSDictionary {
                    let dataItemBTS = DataItemBTS(uuid: UUID())
                    dataItemBTS.allowsVOIP = ((device.value(forKey: "allowsVOIP") as? NSString)?.boolValue) ?? false
                    dataItemBTS.carrierName = (device.value(forKey: "carrierName") as? String) ?? ""
                    dataItemBTS.currentRadioAccessTechnology = (device.value(forKey: "currentRadioAccessTechnology") as? String) ?? ""
                    dataItemBTS.isoCountryCode = (device.value(forKey: "isoCountryCode") as? String) ?? ""
                    dataItemBTS.mobileCountryCode = (device.value(forKey: "mobileCountryCode") as? String) ?? ""
                    dataItemBTS.mobileNetworkCode = (device.value(forKey: "mobileNetworkCode") as? String) ?? ""
                    _ = data.addDevice(newDevice: dataItemBTS) // přidání dat do pole
                }
            }
        }
        
        // BLE SCANS
        if let bleScan = document.property(forKey: "bleScans") as? NSArray {
            for item in bleScan {
                if let device = item as? NSDictionary {
                    let deviceName: String = (device.value(forKey: "deviceName") as? String) ?? ""
                    let macAddress: String = (device.value(forKey: "address") as? String) ?? ""
                    let rssi: Int? = ((device.value(forKey: "rssi") as? NSString)?.integerValue)
                    let time: Int? = ((device.value(forKey: "time") as? NSString)?.integerValue)
                    if (rssi != nil && time != nil), let uuid = UUID(uuidString:(device.value(forKey: "uuid") as? String) ?? "") {
                        let dataItemBLE = DataItemBLE(uuid: uuid, address: macAddress, deviceName: deviceName )
                        dataItemBLE.deviceName = deviceName
                        _ = data.addDevice(newDevice: dataItemBLE)
                        data.addValueBle(uuid: uuid, rssi: rssi!, elapsedTime: time!)
                    }
                }
            }
        }
        
        // GEOLOCATION SCAN
        if let geolocationScan = document.property(forKey: "geolocation") as? NSArray {
            let uuid = UUID() // náhodně vygenerované sdílené uuid (zařízení pro GPS je pouze jedno)
            let dataItemGPS = DataItemGPS(uuid: uuid)
            _ = data.addDevice(newDevice: dataItemGPS)
            for item in geolocationScan {
                if let device = item as? NSDictionary {
                    let lat: Double? = ((device.value(forKey: "lat") as? NSString)?.doubleValue)
                    let long: Double? = ((device.value(forKey: "long") as? NSString)?.doubleValue)
                    let time: Int? = ((device.value(forKey: "time") as? NSString)?.integerValue)
                    if (lat != nil && long != nil && time != nil){
                        let coordinates = CLLocationCoordinate2DMake(lat!,long!)
                        data.addValueGPS(uuid: uuid, coordinates: coordinates, elapsedTime: time!)
                    }
                }
            }
        }

        return data
    }
    
    /// Statická funkce vrátí pole instancí této třídy (DataHolder), které jsou naplněny daty z databáze
    /// Pokud nejsou žádná data k dispozici, vrátí se prázdné pole.
    /// Vracejí se pouze data naměřená na zařízeních se systémem iOS.
    /// Interně volá funkci ImportDocument
    ///
    /// - Returns: Databáze jako pole DataHolder
    static func importDatabase() -> [DataHolder] {
        
        var collectedData = [DataHolder]()
        
        if let database = try? CBLManager.sharedInstance().databaseNamed(SettingsManager.sharedInstance.localDbName) {
            let query = database.createAllDocumentsQuery() // získá všechny dokumenty
            if let result = try? query.run() {
                
                // projít jednotlivé záznamy
                while let document = result.nextRow()?.document
                {
                    if let osName = document.property(forKey: "osName") as? String
                    {
                        // kontrola (insensitive) zda se jedná o iOS
                        if (osName.caseInsensitiveCompare("IOS") == ComparisonResult.orderedSame) {
                            let dataHolder = importDocument(document: document)
                            collectedData.append(dataHolder)
                        }
                    }
                }
            }
        }

        return collectedData.sorted(by: { $0 < $1 })
    }
    
    /// Statická funkce podepíše předaným couchID všechny záznamy, které se nacházejí v lokální databázi, nemají vyplněné ID uživatele a byly pořízeny na tomto zařízení
    ///
    /// - Parameter couchID: unikátní ID uživatele
    static func signData(couchID: String) {
        
        if let database = try? CBLManager.sharedInstance().databaseNamed(SettingsManager.sharedInstance.localDbName) {
            let query = database.createAllDocumentsQuery() // získá všechny dokumenty
            if let result = try? query.run() {
                
                // projít jednotlivé záznamy
                while let document = result.nextRow()?.document
                {
                    let docDeviceID = document.property(forKey: "deviceId") as? String
                    let docCouchID = document.property(forKey: "couchbase_sync_gateway_id") as? String
                    // hledání záznamu který byl pořízen na tomto zařízení a nebyl podepsán
                    if docDeviceID?.caseInsensitiveCompare((UIDevice.current.identifierForVendor?.uuidString)!) == ComparisonResult.orderedSame && docCouchID?.caseInsensitiveCompare("-") == ComparisonResult.orderedSame
                    {
                        var properties = document.properties!
                        properties["couchbase_sync_gateway_id"] = couchID
                        if let _ = try? document.putProperties(properties) {}
                    }
                }
            }
        }
    }
    
    
    
    // MARK: - SORTERY - DEFINOVÁNÍ JAK MÁ BÝT TŘÍDA POROVNÁVÁNA pomocí operátorů <=>
    
    // Tyto metody mají vliv na řazení pole. 
    // Třída je řazena na základě hodnoty v proměnné collectStartTime
    // Itemy které jsou nil jsou řazeny až na konci
    
    
    /// Chování operátoru < (je menší než). 
    /// Prvek který je nil je řazen na konci.
    ///
    /// - Parameters:
    ///   - first: první porovnávaná hodnota
    ///   - second: druhá porovnávaná hodnota
    /// - Returns: vrací true pokud je první hodnota menší než druhá, jinak false
    public static func <(first: DataHolder, second: DataHolder) -> Bool {
        
        if first.collectStartTime == nil {return false}
        if second.collectStartTime == nil {return true}
        return first.collectStartTime! < second.collectStartTime!
    }
    
    /// Chování operátoru > (je větší než)
    /// Prvek který je nil je řazen na konci
    ///
    /// - Parameters:
    ///   - first: první porovnávaná hodnota
    ///   - second: druhá porovnávaná hodnota
    /// - Returns: vrací true pokud je první honnota větší než druhá, jinak false
    public static func >(first: DataHolder, second: DataHolder) -> Bool {
        
        if first.collectStartTime == nil {return false}
        if second.collectStartTime == nil {return true}
        return first.collectStartTime! > second.collectStartTime!
    }
    
}
