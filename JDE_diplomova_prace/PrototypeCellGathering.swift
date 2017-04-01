
import UIKit



/// Vzorová buňka tabulky pro náhled naměřených dat během probíhajícího měření
class PrototypeCellGathering: UITableViewCell {


    
    // MARK: - PROMĚNNÉ
    
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelUUID: UILabel!
    @IBOutlet var labelValue: UILabel!
    @IBOutlet var imageDeviceType: UIImageView!
    
    
    
    // MARK: - FUNKCE
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    /// Zobrazí v aktuální buňce data, zaslaná v parametru
    ///
    /// - Parameter rowData: data buňky
    func showData(rowData: ProtocolWirelessManager) {

        labelName.text = rowData.stringDeviceName()
        labelValue.text = ("\(rowData.stringValue())")
        labelUUID.text = rowData.uuid.uuidString
        labelUUID.isHidden = rowData.uuidIsHidden
        
        // výběr obráízku
        if rowData is DataItemBLE {
            imageDeviceType.image=UIImage(named: "bluetooth")
        }
        else if rowData is DataItemGPS {
            imageDeviceType.image=UIImage(named: "gps")
        }
        else if rowData is DataItemWIFI {
            imageDeviceType.image=UIImage(named: "wifi")
        }
        else if rowData is DataItemBTS {
            imageDeviceType.image=UIImage(named: "gsm")
        }
    }

}
