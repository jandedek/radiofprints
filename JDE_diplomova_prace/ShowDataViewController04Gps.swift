
import UIKit
import CoreLocation



/// Controller obsluhuje čtvrtý view pro seznam GPS hodnot
class ShowDataViewController04Gps: UITableViewController {


    
    // MARK: - PROMĚNNÉ
    
    /// Naměřená data k zobrazení
    public var collectedData: [(location: CLLocationCoordinate2D, elapsedTime: Int)] = []
    
    
    
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrototypeCellShowDataGps", for: indexPath) as! PrototypeCellShowDataGps //použití připraveného prototypu buňky
        let dataRow = collectedData[indexPath.row] // data pro aktuální řádek
        
        cell.lblLat.text = dataRow.location.latitude.description
        cell.lblLong.text = dataRow.location.longitude.description
        cell.lblElapsedTime.text = ("\(dataRow.elapsedTime) ms")
        
        return cell
    }
}
