
import UIKit



/// Controller obsluhuje view pro sběr dat - procházka (výběr scénáře)
class DataCollectionViewController03a: UITableViewController {


    
    // MARK: - UDÁLOSTI
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true //schování tab baru
    }

    /// Příprava view s mapou předtím, než je samotný view zobrazen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueCollectDataWalkMap" {
            
            let selectedCell = sender as? PrototypeCellSelectScenario
            let destinationView = segue.destination as? DataCollectionViewController04a
            
            if selectedCell != nil && destinationView != nil {
                destinationView?.scenario = selectedCell?.scenario
                destinationView?.map = selectedCell?.map
            }
        }
    }

    
    
    // MARK: - DELEGÁTI TABLE VIEW

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return SettingsManager.sharedInstance.listOfScenarios.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrototypeCellSelectScenario", for: indexPath) as! PrototypeCellSelectScenario
        let scenarioForRow = SettingsManager.sharedInstance.listOfScenarios.sorted(by: {$0.value.name < $1.value.name})[indexPath.row]
        let mapForRow = SettingsManager.sharedInstance.listOfMaps[scenarioForRow.value.mapID]
        cell.scenario = scenarioForRow.value
        cell.map = mapForRow
        cell.lblScenarioName.text = scenarioForRow.value.name
        cell.lblLocation.text = mapForRow?.description ?? ""
        
        return cell
    }
    
}
