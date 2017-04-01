
import UIKit
import CoreLocation



/// Controller obsluhuje první view pro sběr dat (popis funkcionality)
class DataCollectionViewController01: UIViewController {


    
    // MARK: - PROMĚNNÉ
    
    @IBOutlet weak var btnContinue: UIBarButtonItem!
    private let locationManager = CLLocationManager()
    
    
    
    // MARK: - UDÁLOSTI
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {

        self.tabBarController?.tabBar.isHidden = false //zobrazení tab baru
        
        // kontrola zda je v nastavení povolen sběr dat z alespoň jedné sítě. Pokud ne tlačítko "Zahájit měření bude neaktivní"
        btnContinue.isEnabled = SettingsManager.sharedInstance.useBluetooth || SettingsManager.sharedInstance.useBTS || SettingsManager.sharedInstance.useGPS || SettingsManager.sharedInstance.useWiFi
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
 
}
