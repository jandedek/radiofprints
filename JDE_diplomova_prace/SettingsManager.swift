
import UIKit




/// Tato třída se stará o načítání/ukládání nastavení
/// Třída je singleton
class SettingsManager: NSObject
{

    // MARK: - PROMĚNNÉ
    
    // defaultní hodnoty
    private let defaultUseBluetooth:Bool = true
    private let defaultUseWiFi:Bool = true
    private let defaultUseBTS:Bool = true
    private let defaultUseGPS:Bool = true
    private let defaultCountDown:Int = 20
    private let defaultWalkingSpeedCorrection:Int = 0
    
    //private let defaultConfigFileURL:String = "http://api.myjson.com/bins/127a4r"
    private let defaultConfigFileURL:String = "http://beacon.uhk.cz/app-config.json"


    
    // veřejné proměnné
    
    /// statická property pro přístup k singleton isntanci třídy
    public static let sharedInstance = SettingsManager()
    
    /// Indikuje zda je do měření zahrnuto bluetooth (defaultně true)
    public var useBluetooth:Bool = true
    
    /// Indikuje zda jsou do měření zahrnuty WiFi sítě (defaultně true)
    public var useWiFi:Bool = true
    
    /// Indikuje zda je do měření zahrnuta BTS (defaultně true)
    public var useBTS:Bool = true
    
    /// Indikuje zda je do měření zahrnuta GPS (defaultně true)
    public var useGPS:Bool = true
    
    /// Určuje délku měření v sekundách (defaultně 20)
    public var countDown:Int = 20
    
    /// Přizpůsobení rychlosti chůze u procházky
    public var walkingSpeedCorrection:Int = 0
    
    /// Obsahuje URL na které je spuštěna služba (resp. gateway) couchbase databáze
    public var gatewayURL:String = ""
    
    /// Obsahuje URL logovací stránky
    public var loginURL:String = ""
    
    /// Obsahuje URL konfiguračního souboru scénářů testování
    // TODO: Pouze test do produkce smazat a načítat z konfiguráku
    public var scenariosURL:String = ""
    
    //Obsahuje adresu konfiguračního souboru
    public var configFileURL:String = "http://beacon.uhk.cz/app-config.json"
    
    /// Název lokální databáze (konstanta)
    public let localDbName:String = "localdb"
    
    /// Seznam mapových podkladů
    public var listOfMaps = [String: (location: String, description: String, mapURL: URL, mapID: String)]() // vytvoření slovníku - KEY = mapID
    
    ///
    public var listOfScenarios = [String: (scenarioID: String, name: String, mapID: String, points: [(x: Int, y: Int)])]() // vvytvoření slovníku - KEY = scenarioID
    
    
    
    // privátní konstruktor (třída je singleton)
    private override init() {
        
        super.init()
        loadSettings()
        loadJsonConfigFile()
    }



    // MARK: - FUNKCE
    
    /// Načtení uložených dat
    func loadSettings() {
        
        // nejprve je provedena kontrola zda existuje hodnota pro daný klíč
        // pokud existuje, je hodnota načtena a uložena do property
        // pokud neexistuje, je ponechána v property defaultní hodnota
        
        let userSettings = UserDefaults.standard
        
        if userSettings.object(forKey: "useBluetooth") != nil { useBluetooth = userSettings.bool(forKey: "useBluetooth") }
        if userSettings.object(forKey: "useWiFi") != nil { useWiFi = userSettings.bool(forKey: "useWiFi") }
        if userSettings.object(forKey: "useBTS") != nil { useBTS = userSettings.bool(forKey: "useBTS") }
        if userSettings.object(forKey: "useGPS") != nil { useGPS = userSettings.bool(forKey: "useGPS") }
        if userSettings.object(forKey: "countDown") != nil { countDown = userSettings.integer(forKey: "countDown") }
        if userSettings.object(forKey: "configFileURL") != nil { configFileURL = userSettings.string(forKey: "configFileURL")! }
        if userSettings.object(forKey: "walkingSpeedCorrection") != nil { walkingSpeedCorrection = userSettings.integer(forKey: "walkingSpeedCorrection") }
    }
    
    /// Uložení nastavených hodnot
    func saveSettings() {
        
        let userSettings = UserDefaults.standard
        
        userSettings.set(useBluetooth, forKey: "useBluetooth")
        userSettings.set(useWiFi, forKey: "useWiFi")
        userSettings.set(useBTS, forKey: "useBTS")
        userSettings.set(useGPS, forKey: "useGPS")
        userSettings.set(countDown, forKey: "countDown")
        userSettings.set(configFileURL, forKey: "configFileURL")
        userSettings.set(walkingSpeedCorrection, forKey: "walkingSpeedCorrection")
        
        userSettings.synchronize()
        loadJsonConfigFile()
    }
    
    /// nastaví defaultní hodnoty a uloží je
    func resetToDefaults() {
        
        useBluetooth = defaultUseBluetooth
        useWiFi = defaultUseWiFi
        useBTS = defaultUseBTS
        useGPS = defaultUseGPS
        countDown = defaultCountDown
        configFileURL = defaultConfigFileURL
        walkingSpeedCorrection = defaultWalkingSpeedCorrection
        
        saveSettings()
        
    }
    
    /// Načte z internetu konfigurační soubor
    func loadJsonConfigFile() {

        self.listOfMaps.removeAll()
        self.gatewayURL = ""
        self.loginURL = ""
        self.scenariosURL = ""
        
        if let url = URL(string: configFileURL) {

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }

                do {
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    

                    // získání URL adres z konfiguračního souboru
                    self.gatewayURL = jsonResult["gatewayURL"] as? String ?? ""
                    self.loginURL = jsonResult["authURL"] as? String ?? ""
                    self.scenariosURL = jsonResult["scenariosURL"] as? String ?? ""
               
                    // získání mapových podkladů z konfiguračního souboru
                    if let maps : [NSDictionary] = jsonResult["maps"] as? [NSDictionary] {
                        for map: NSDictionary in maps {
                            
                            let jsonDescription = map["description"] as? String ?? ""
                            let jsonID = map["id"] as? String ?? ""
                            let jsonLocation = map["location"] as? String ?? ""
                            let jsonMapURL = map["mapURL"] as? String ?? ""
                            
                            // Pokud je URL mapy validní, dojde ke vložení mapy do kolekce
                            if let convertedURL = URL(string: jsonMapURL) {
                                self.listOfMaps.updateValue((location: jsonLocation, description: jsonDescription, mapURL: convertedURL, mapID: jsonID), forKey: jsonID)
                            }
                        }
                    }
                    
                    self.loadJsonScenariosFile()
                    
                }catch{}
            }
            task.resume()
        }
    }
    
    /// Načte z internetu konfigurační soubor testovaích scénářů ve formě JSON
    func loadJsonScenariosFile() {
        
        self.listOfScenarios.removeAll()

        if let url = URL(string: scenariosURL) {
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }
                
                do {
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    // získání seznamu scénářů z konfiguračního souboru
                    if let scenarios : [NSDictionary] = jsonResult["scenarios"] as? [NSDictionary] {
                        for scenario: NSDictionary in scenarios {
                            
                            let jsonScenarioID = scenario["scenarioID"] as? String ?? ""
                            let jsonScenarioName = scenario["name"] as? String ?? ""
                            let jsonMapID = scenario["mapID"] as? String ?? ""
                            var jsonPoints = [(x: Int, y: Int)]()

                            if let points : [NSDictionary] = scenario["points"] as? [NSDictionary] {
                                for point: NSDictionary in points {
                                    let x = point["X"] as? Int ?? 0
                                    let y = point["Y"] as? Int ?? 0
                                    jsonPoints.append((x: x, y: y))
                                }
                            }
                            
                            // přidání scénáře do seznamu
                            self.listOfScenarios.updateValue((scenarioID: jsonScenarioID, name: jsonScenarioName, mapID: jsonMapID, points: jsonPoints), forKey: jsonScenarioID)
                        }
                    }
                    
                }catch{}
            }
            task.resume()
        }
        
        
        
    }
 
}
