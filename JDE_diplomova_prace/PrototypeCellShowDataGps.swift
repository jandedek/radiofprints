
import UIKit



/// Vzorová buňka tabulky pro zobrazení naměřených GPS hodnot
class PrototypeCellShowDataGps: UITableViewCell {


    
    // MARK: - PROMĚNNÉ
    
    @IBOutlet weak var lblLong: UILabel!
    @IBOutlet weak var lblLat: UILabel!
    @IBOutlet weak var lblElapsedTime: UILabel!

    
    
    // MARK: - FUNKCE
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }

}
