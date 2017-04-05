
import UIKit



/// Vzorová buňka tabulky pro zobrazení seznamu měření
class PrototypeCellShowData: UITableViewCell {


    
    // MARK: - PROMĚNNÉ
    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    /// Data načtená z databáze vztahující se k této buňce
    public var rowData: DataHolder?
    
    /// Unikátní identifikátor mapy (level)
    public var mapID: String?
    
    /// Data mapy
    public var mapData: (location: String, description: String, mapURL: URL, mapID: String)?
    
    
    
    // MARK: - FUNKCE
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }

}
