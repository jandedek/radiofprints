
import UIKit



/// Controller obsluhuje view pro sběr dat - měření na místě (výběr lokace)
class DataCollectionViewController03b: UITableViewController {

    
    
    // MARK: - UDÁLOSTI
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true //schování tab baru
    }
    
    /// Příprava view s mapou předtím, než je samotný view zobrazen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueCollectDataMap" {
            
            let selectedCell = sender as? PrototypeCellSelectMap
            let destinationView = segue.destination as? DataCollectionViewController04b
            
            if selectedCell != nil && destinationView != nil {
                
                destinationView?.mapURL = selectedCell?.mapURL
                destinationView?.mapID = selectedCell?.mapID
            }
        }
    }
    
    
    
    // MARK: - DELEGÁTI TABLE VIEW

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return SettingsManager.sharedInstance.listOfMaps.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       //použití připraveného prototypu buňky
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrototypeCellSelectMap", for: indexPath) as! PrototypeCellSelectMap
        let dataRow = SettingsManager.sharedInstance.listOfMaps.sorted(by: {$0.key < $1.key})[indexPath.row]
        cell.labelLocation.text = dataRow.value.location
        cell.labelDetail.text = dataRow.value.description
        cell.mapURL = dataRow.value.mapURL
        cell.mapID = dataRow.value.mapID

        return cell
    }
    
}
