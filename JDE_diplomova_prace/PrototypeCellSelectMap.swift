
import UIKit



/// Vzorová buňka tabulky pro výbět mapy
class PrototypeCellSelectMap: UITableViewCell
{

    
    
    // MARK: - PROMĚNNÉ
    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var labelDetail: UILabel!
    public var mapURL:URL?
    public var mapID:String?
    
    
    // MARK: - FUNKCE
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }

}
