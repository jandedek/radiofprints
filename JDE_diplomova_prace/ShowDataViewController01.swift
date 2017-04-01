
import UIKit



/// Controller obsluhuje první view pro náhled naměřených hodnot (popis funkcionality)
class ShowDataViewController01: UIViewController {

    
    
    // MARK: - PROMĚNNÉ
    
    private var collectedData:[DataHolder]?
    
    
    
    // MARK: - UDÁLOSTI

    override func viewDidLoad() {
        
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false //zobrazení tab baru
    }
    
    /// Příprava dat pro tabulku na ShowDataViewController02
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "segueShowDataList" && collectedData != nil {
            let destinationView = segue.destination as? ShowDataViewController02
        
            if destinationView != nil {
                destinationView?.collectedData = collectedData!
                collectedData=nil
            }
        }
    }
    
    /// Kontrola zda jsou nějaká data k zobrazení. Pokud ne, aplikace nepřejde na další view
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {

        if identifier == "segueShowDataList" {
            collectedData = DataHolder.importDatabase()
            if collectedData!.count == 0 {
                // pokud nejsou žádná data k zobrazení, zobrazit hlášku
                let alert = UIAlertController(title: "Žádná data k zobrazení", message: "Nejsou k dispozici žádná data k zobrazení. Nejprve synchronizujte databázi nebo proveďte měření", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                return false
            }
        }
        
        return true
    }
    
}
