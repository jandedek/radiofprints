
import UIKit



/// Vzorová buňka tabulky pro zobrazení naměřených BLE hodnot
class PrototypeCellShowDataBluetooth: UITableViewCell {

    

    // MARK: - PROMĚNNÉ
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUuid: UILabel!
    @IBOutlet weak var lblRssi: UILabel!
    @IBOutlet weak var lblElapsedTime: UILabel!
    
    
    
    // MARK: - FUNKCE
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }

}
