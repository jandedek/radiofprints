
import UIKit



/// Controller obsluhuje třetí view pro náhled naměřených hodnot (kořenový element pro přepínání panelů)
class ShowDataViewController03Parent: UIViewController {


    
    // MARK: - PROMĚNNÉ
    
    @IBOutlet weak var viewControllerValues: UIView!
    @IBOutlet weak var viewControllerMap: UIView!
    private var mapView: ShowDataViewController03Map?
    private var valuesView: ShowDataViewController03Values?
    
    /// Naměřená data k zobrazení
    var collectedData: DataHolder?
    
    /// Data k mapě
    var mapData: (location: String, description: String, mapURL: URL, mapID: String)?
    
    
    
    // MARK: - UDÁLOSTI
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true //schování tab baru
    }
    
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            viewControllerValues.isHidden = false
            viewControllerMap.isHidden = true
        }
        else {
            viewControllerMap.isHidden = false
            viewControllerValues.isHidden = true
        }
    }
    
    /// Příprava view s mapou předtím, než je samotný view zobrazen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "segueShowDataDetailValues" {
            let valuesView = segue.destination as? ShowDataViewController03Values
            valuesView?.collectedData = collectedData
            valuesView?.mapData = mapData
        }
        else if segue.identifier == "segueShowDataDetailMap" {
            let mapView = segue.destination as? ShowDataViewController03Map
            mapView?.mapCoord = CGPoint(x: collectedData?.mapX ?? 0, y: collectedData?.mapY ?? 0)
            mapView?.mapURL = mapData?.mapURL
        }
    }

}
