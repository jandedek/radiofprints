
import UIKit



/// Controller obsluhuje první view pro synchronizaci dat (popis funkcionality)
class SynchronizeViewController01: UIViewController {

    
    
    // MARK: - UDÁLOSTI
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false //zobrazení tab baru
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }

}
