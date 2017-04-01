
import UIKit



/// Vzorová buňka tabulky pro výbět scénáře
class PrototypeCellSelectScenario: UITableViewCell {

    
    
    // MARK: - PROMĚNNÉ
    @IBOutlet weak var lblScenarioName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    public var scenario : (scenarioID: String, name: String, mapID: String, points: [(x: Int, y: Int)])?
    public var map : (location: String, description: String, mapURL: URL, mapID: String)?

    
    
    // MARK: - FUNKCE
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

    }

}
