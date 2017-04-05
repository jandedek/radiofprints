
import UIKit



/// Controller obsluhuje druhý view pro sběr dat - výběr typu měření (procházka/měření na místě)
class DataCollectionViewController02: UITableViewController {

    
    
    // MARK: - UDÁLOSTI
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true //schování tab baru
    }


}
