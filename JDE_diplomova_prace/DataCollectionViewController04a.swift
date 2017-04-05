
import UIKit
import CoreMotion
import CoreLocation



/// Controller obsluhuje view pro sběr dat - procházka (mapa a měření)
class DataCollectionViewController04a: UIViewController, UIWebViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, WirelessManagerDelegate {

    
    
    // MARK: - PROMĚNNÉ
    
    @IBOutlet weak var mapWebView: UIWebView!
    @IBOutlet weak var webActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet weak var btnStartStop: UIBarButtonItem!

    /// Mapa
    public var map : (location: String, description: String, mapURL: URL, mapID: String)?
    
    /// Scénář
    public var scenario : (scenarioID: String, name: String, mapID: String, points: [(x: Int, y: Int)])?
    
    private var lastScaleValue: CGFloat = 1.0 // pomocná proměnná která udržuje hodnotu přiblížení mezi gesty
    private var walkingInProgress: Bool = false     // indikuje zda je prováděn pohyb po mapě (true) nebo bylo dosaženo cílového bodu (false)
    private var measurementInProgress: Bool = false // indikuje mezistavy mezi měřeními, zda jsou aktuálně sbírána data (true) nebo probíhá jejich shromažďování před začákem nového měření (false)
    private var timerWalkStep: Timer?
    private var timerNewMeasurement: Timer = Timer()
    private var pointsGenerator: WalkingPointsGenerator?
    private var lastPoint: (x: Int, y: Int)?
    private var currentDataHolder: DataHolder? // dataholder který je aktuálně plněný daty
    private var listOfDataHolders = [DataHolder]() // kolekce dataholderů (záznamů všech měření)
    private var listOfDevices = [UUID: ProtocolWirelessManager]() // seznam vše zařízení která se připojila udržovaný mezi měřeními
    private let bleManager = ManagerBLE() // vytvoření nové instance bluetooth managera
    private let gpsManager = ManagerGPS() // vytvoření nové instance GPS managera
    private let btsManager = ManagerBTS() // vytvoření nové instance BTS managera
    private let wifiManager = ManagerWIFI() // vytvoření nové instance WiFi managera
    private let motionManager = CMMotionManager()
    private var startTime: Date? // čas začátku měření
    
    
    
    // MARK: - UDÁLOSTI
    
    override func viewDidLoad() {

        super.viewDidLoad()
        mapWebView.delegate = self
        mapWebView.scrollView.delegate = self // detekce scrollování (= změna souřadnic)
        pinchGestureRecognizer.delegate=self
        
        bleManager.delegate = self
        gpsManager.delegate = self
        btsManager.delegate = self
        wifiManager.delegate = self
        motionManager.startGyroUpdates()
        motionManager.startMagnetometerUpdates()
        
        if (SettingsManager.sharedInstance.useBluetooth) {bleManager.start()}
        if (SettingsManager.sharedInstance.useGPS) {gpsManager.start()}
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true //schování tab baru
        pointsGenerator = WalkingPointsGenerator(walkingPoints: scenario?.points)
        
        if map?.mapURL != nil {
            mapWebView.loadRequest(URLRequest(url: map!.mapURL)) // adresa je ok
        }
        else {
            // nevalidní URL - zobrazit upozornění
            let alert = UIAlertController(title: "Nevalidní URL mapy", message: "Mapa není k dispozici", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// stisknutí tlačítka start/stop
    @IBAction func btnStartStopPressed(_ sender: UIBarButtonItem) {
        
        if walkingInProgress { interruptWalking() }
        else { startWalking() }
        
    }

    /// Funkce volaná timerem pro pohyb na mapě při každém ticku
    ///
    /// - Parameter timer: objekt který funkci zavolal
    func timerWalkStepTick(timer: Timer) {

        let newPoint: (x: Int, y: Int)? = pointsGenerator!.getNextPoint()
        
        if newPoint == nil {
            
            timerWalkStep?.invalidate()
            walkingInProgress = false
        }
        else {
        
            mapWebView.stringByEvaluatingJavaScript(from: "scrollToLogicXY(\(newPoint!.x), \(newPoint!.y))") // nastavení pozice mapy
            lastPoint = newPoint
        }
    }
    
    /// Funkce volaná timerem pro oddělení jednotlivých měření (voláno každé 2 sekundy)
    func timerStartNewMeasurementTick(timer: Timer) {
       
        objc_sync_enter(measurementInProgress)
        measurementInProgress = false
        objc_sync_exit(measurementInProgress)
        
        
        // ukončení předchozího měření pokud probíhalo
        if currentDataHolder != nil {
            
            currentDataHolder!.collectEndTime = Date()
            currentDataHolder!.createdAt = Date()
            
            // získání dat z gyroskopu
            if let gyroData = motionManager.gyroData {
                currentDataHolder!.gyroX = gyroData.rotationRate.x
                currentDataHolder!.gyroY = gyroData.rotationRate.y
                currentDataHolder!.gyroZ = gyroData.rotationRate.z
            }
            
            // získání dat z magnetometru
            if let magnetoData = motionManager.magnetometerData {
                currentDataHolder!.magnetoX = magnetoData.magneticField.x
                currentDataHolder!.magnetoY = magnetoData.magneticField.y
                currentDataHolder!.magnetoZ = magnetoData.magneticField.z
            }
        }
        
        
        // pokud ještě nebylo dosaženo cíle, začít nové měření
        if walkingInProgress {

            objc_sync_enter(pointsGenerator)
            let currentPoint: (x: Int, y: Int)? = pointsGenerator!.getCurrentPoint()
            objc_sync_exit(pointsGenerator)
            
            startTime = Date()
            
            currentDataHolder = DataHolder()
            listOfDataHolders.append(currentDataHolder!)
            currentDataHolder!.level = scenario?.mapID
            currentDataHolder!.mapX = Int(currentPoint?.x ?? 0)
            currentDataHolder!.mapY = Int(currentPoint?.y ?? 0)
            currentDataHolder!.collectStartTime = startTime
            
            objc_sync_enter(measurementInProgress)
            measurementInProgress = true
            objc_sync_exit(measurementInProgress)
            
            if (SettingsManager.sharedInstance.useWiFi) {wifiManager.start()}
            if (SettingsManager.sharedInstance.useBTS) {btsManager.start()}
            
            if (SettingsManager.sharedInstance.useGPS) {
                objc_sync_enter(gpsManager)
                gpsManager.requestLocation()
                objc_sync_exit(gpsManager)
            }
            
            
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.timerStartNewMeasurementTick), userInfo: nil, repeats: false)
            
        }
        else {
            // bylo dosaženo cíle - nové měření nezačínat
            walkingFinished()
        }
        
        
    }
    
    
    
    // MARK: - FUNKCE
    
    /// Spustí procházku
    private func startWalking() {
        
        self.navigationItem.setHidesBackButton(true, animated:true) // skrytí tlačítka zpět
        walkingInProgress = true
        btnStartStop.title = "Zrušit měření"

        let interval = 0.02 + (Double(SettingsManager.sharedInstance.walkingSpeedCorrection) / -1000.0)
        timerWalkStep = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.timerWalkStepTick), userInfo: nil, repeats: true)
        timerStartNewMeasurementTick(timer: timerNewMeasurement)
    }
    
    /// Fukce po úspěšném zavolání procházky uloží data do databáze
    private func walkingFinished() {
     
        btnStartStop.isEnabled = false
        bleManager.stop()
        gpsManager.stop()
        motionManager.stopGyroUpdates()
        motionManager.stopMagnetometerUpdates()
        saveDataToDatabase()

        // měření bylo dokončeno
        let alert = UIAlertController(title: "Hotovo", message: "Měření bylo dokončeno", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
            self.performSegue(withIdentifier: "segueCollectingWalkingBackToRootNavigationController", sender: self) // zpět na úvodní view
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Na základě požadavku uživatele přeruší procházku. Nedojde k uložení dat.
    private func interruptWalking() {
        
        timerWalkStep?.invalidate()
        timerNewMeasurement.invalidate()
        bleManager.stop()
        gpsManager.stop()
        motionManager.stopGyroUpdates()
        motionManager.stopMagnetometerUpdates()
        
        // měření bylo zrušeno
        let alert = UIAlertController(title: "Pozor", message: "Měření bylo zrušeno, data nebyla uložena", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
            self.performSegue(withIdentifier: "segueCollectingWalkingBackToRootNavigationController", sender: self) // zpět na úvodní view (bez uložení dat)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Uložení dat do databáze
    func saveDataToDatabase() {
        
        if let database = try? CBLManager.sharedInstance().databaseNamed(SettingsManager.sharedInstance.localDbName) {
            for data in listOfDataHolders {
                let document = database.createDocument()
                _ = try? document.putProperties(data.exportToJson())
            }
        }
    }


    
    // MARK: - DELEGÁTI WIRELESS MANAGERŮ
    
    /// Připojení k BLE zařízení navázáno
    ///
    /// - Parameter newDevice: připojené zařízení
    func deviceDidConnect(newDevice: ProtocolWirelessManager) {

        objc_sync_enter(listOfDevices)
        listOfDevices.updateValue(newDevice, forKey: newDevice.uuid) // zkusit přidat zařízení do seznamu
        objc_sync_exit(listOfDevices)
        
        if measurementInProgress {
           _ = currentDataHolder?.addDevice(newDevice: newDevice)
        }
    }
    
    /// Obdržení nově naměřené hodnoty z BLE zařízení
    ///
    /// - Parameters:
    ///   - uuid: unikátní identifikátor zařízení
    ///   - rssi: síla signálu
    func bleDataReceived (uuid:UUID, rssi: Int) {
        
        if measurementInProgress {
            objc_sync_enter(startTime)
            let elapsedTime:Int = (Int)((startTime?.timeIntervalSinceNow)! * (-1000)) // čas od začátku měření v millisekundách
            objc_sync_exit(startTime)
            
            objc_sync_enter(listOfDevices)
            if let device = listOfDevices[uuid] { _ = currentDataHolder?.addDevice(newDevice: device) } // zkusit přidat zařízení
            objc_sync_exit(listOfDevices)
            
            currentDataHolder?.addValueBle(uuid: uuid, rssi: rssi, elapsedTime: elapsedTime)
        }

    }
    
    /// Obdržení nové naměřené hodnoty z GPS
    ///
    /// - Parameters:
    ///   - uuid: unikátní identifikátor zařízení
    ///   - coordinates: zeměpisné souřadnice
    func gpsDataReceived(uuid: UUID, coordinates: CLLocationCoordinate2D) {
        
        if measurementInProgress {
            objc_sync_enter(startTime)
            let elapsedTime:Int = (Int)((startTime?.timeIntervalSinceNow)! * (-1000)) // čas od začátku měření v millisekundách
            objc_sync_exit(startTime)
            
            objc_sync_enter(listOfDevices)
            if let device = listOfDevices[uuid] { _ = currentDataHolder?.addDevice(newDevice: device) } // zkusit přidat zařízení
            objc_sync_exit(listOfDevices)
            
            currentDataHolder?.addValueGPS(uuid: uuid, coordinates: coordinates, elapsedTime: elapsedTime)
        }
    }
    
    
    
    // MARK: - DELEGÁTI WEB VIEW
    
    /// Po dokončení scrollování nastavit zpět aktuální souřadnice
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let currentPoint = pointsGenerator!.getCurrentPoint()
        if currentPoint != nil { mapWebView.stringByEvaluatingJavaScript(from: "scrollToLogicXY(\(currentPoint!.x), \(currentPoint!.y))") } // nastavení pozice mapy
    }
    
    /// webView začal načítat stránku
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        lastScaleValue = 1.0 // každá nově načtená stránka má scale = 1 (bez přiblížení nebo oddálení)
        webActivityIndicator.startAnimating()
        btnStartStop.isEnabled = false
    }
    
    /// po načtení stránky zjistit aktuální souřadnice
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        mapWebView.stringByEvaluatingJavaScript(from: "document.getElementById('zoom-in').hidden='hidden';") // skrytí tlačítka zoom-in
        mapWebView.stringByEvaluatingJavaScript(from: "document.getElementById('zoom-out').hidden='hidden';") // skrytí tlačítka zoom-out
        webActivityIndicator.stopAnimating()
        
        let startingPoint: (x: Int, y: Int)? = pointsGenerator!.getCurrentPoint()

        if startingPoint == nil {
            
            btnStartStop.isEnabled = false
            
            // nejsou k dispozici žádné body
            let alert = UIAlertController(title: "Pozor", message: "Scénář neobsahuje body definující cestu", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            mapWebView.stringByEvaluatingJavaScript(from: "scrollToLogicXY(\(startingPoint!.x), \(startingPoint!.y))") // nastavení pozice mapy
            btnStartStop.isEnabled = true
        }

        
    }
    
    /// chyba při načítání stránky
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        print("didFailLoadWithError: \(error.localizedDescription)")
        
        webActivityIndicator.stopAnimating()
        
        // nevalidní URL - zobrazit upozornění
        let alert = UIAlertController(title: "Otevírání stránky selhalo", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// změna velikosti nebo orientace view - refresh stránky s mapou
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        mapWebView.reload()
    }
    
    /// rospoznání gesta Pinch (zoom stránky)
    @IBAction func gestureDidUse(_ sender: UIPinchGestureRecognizer) {
        
        let minScale: CGFloat = 0.5 // spodní hranice zoomu
        let maxScale: CGFloat = 1.5 // horní hranice zoomu
        
        // nastavení hranic zoomu
        if sender.scale < minScale {sender.scale = minScale}
        else if sender.scale > maxScale {sender.scale = maxScale}
        
        // pokud se hodnota zoomu nezměnila o víc než 0.025 oproti volání, ve kterém se naposledy provedl zoom, je funkce ukončena
        // (tímto omezením je nastavena citlivost zoomu)
        if abs(lastScaleValue - sender.scale) < 0.025 {return}
        
        // rozlišení zda se jedná o přiblížení nebo oddálení a kontrola zda velikost přiblížení není mimo povolenou hranici
        // sender.velocity < 0 = oddálení
        // sender.velocity > 0 = přiblížení
        if sender.velocity < 0 && sender.scale > minScale {
            mapWebView.stringByEvaluatingJavaScript(from: "document.getElementById('zoom-out').click();") // zavolání eventu "click" tlačítka zoom-out
        }
        else if sender.velocity > 0 && sender.scale < maxScale {
            mapWebView.stringByEvaluatingJavaScript(from: "document.getElementById('zoom-in').click();") // zavolání eventu "click" tlačítka zoom-in
        }
        
        lastScaleValue = sender.scale
    }
    
    /// začátek nového gesta
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // na začátku nového gesta se doplní poslední scale hodnota.
        // Tato funkce je zde proto, že si UIPinchGestureRecognizer nepamatuje stav mezi jednotlivými gesty
        // a díky tomu je je možné obejít min a max hranici přiblížení (pokud toto není ošetřeno na úrovni javascriptu)
        if let pinchGesture = gestureRecognizer as? UIPinchGestureRecognizer {
            pinchGesture.scale = lastScaleValue
        }
        
        return false
    }

}
