
import UIKit



/// Controller obsluhuje druhý view pro náhled naměřených hodnot (seznam uskutečněných měření)
class ShowDataViewController02: UITableViewController
{
    
    

    // MARK: - PROMĚNNÉ
    
    public var collectedData = [DataHolder]()
    

    
    // MARK: - UDÁLOSTI
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true //schování tab baru
    }

    /// Příprava view s mapou předtím, než je samotný view zobrazen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueShowDataDetail" {
            
            let selectedCell = sender as? PrototypeCellShowData
            let destinationView = segue.destination as? ShowDataViewController03Parent
            
            if selectedCell != nil && destinationView != nil {
                
                destinationView?.collectedData = selectedCell?.rowData
                destinationView?.mapData = selectedCell?.mapData
            }
        }
    }
  
  
    
    // MARK: - DELEGÁTI TABLE VIEW
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 
        return collectedData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        // formát data a času
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        formatter.timeStyle = DateFormatter.Style.medium
        
        //použití připraveného prototypu buňky a naplnění třídy daty
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrototypeCellShowData", for: indexPath) as! PrototypeCellShowData
        cell.rowData = collectedData[indexPath.row]
       
        // informace o mapě
        if let map = SettingsManager.sharedInstance.listOfMaps[cell.rowData?.level ?? ""] {
            cell.mapID = map.mapID
            cell.mapData = map
        }

        // zobrazení dat uživateli
        cell.lblLocation.text = cell.mapData?.location ?? "-"
        cell.lblDescription.text = cell.mapData?.description ?? "-"
        
        if let date = cell.rowData?.collectStartTime {
            cell.lblDate.text = formatter.string(from: date)
        }
        else {
            cell.lblDate.text = "-"
        }
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        return UITableViewCellEditingStyle.delete // akce pro všechny řádky při swipe vlevo
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    
        // podmínka k určení které řádky je možné updatovat (vymazat) a které nikoli
        
        if let cell = tableView.cellForRow(at: indexPath) as? PrototypeCellShowData {
            if cell.rowData?.deviceID != nil && UIDevice.current.identifierForVendor != nil {
                
                // hledání záznamu který byl pořízen na tomto zařízení a nebyl synchronizován (podepsán)
                if cell.rowData!.deviceID!.caseInsensitiveCompare((UIDevice.current.identifierForVendor?.uuidString)!) == ComparisonResult.orderedSame && cell.rowData!.userID?.caseInsensitiveCompare("-") == ComparisonResult.orderedSame
                {
                    return true
                }
            }
        }

        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
    
            
            if let cell = tableView.cellForRow(at: indexPath) as? PrototypeCellShowData {
                if let document = cell.rowData?.databaseDocument {
                    
                    try? document.delete()
                    collectedData.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                }
            }
        }

     }
    
    
}
