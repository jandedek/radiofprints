
import UIKit



/// Controller obsluhuje čtvrtý view pro seznam BLE hodnot
class ShowDataViewController04Ble: UITableViewController {


    
    // MARK: - PROMĚNNÉ
    
    /// Naměřená data k zobrazení
    public var collectedData:[(uuid: UUID, name: String, rssi: Int, elapsedTime: Int)] = []

    
    
    // MARK: - UDÁLOSTI
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true //schování tab baru
    }


    
    // MARK: - DELEGÁTI TABLE VIEW

    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return collectedData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrototypeCellShowDataBluetooth", for: indexPath) as! PrototypeCellShowDataBluetooth //použití připraveného prototypu buňky
        let dataRow = collectedData[indexPath.row] // data pro aktuální řádek
        
        cell.lblName.text = dataRow.name
        cell.lblUuid.text = dataRow.uuid.uuidString
        cell.lblRssi.text = ("\(dataRow.rssi) dB")
        cell.lblElapsedTime.text = ("\(dataRow.elapsedTime) ms")
        
        return cell
    }

}
