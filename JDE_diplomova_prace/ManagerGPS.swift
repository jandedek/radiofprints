
import Foundation
import CoreLocation



/// Třída zajišťuje management GPS modulu a pomocí delegátů informuje třídy které delegáty odebírají o změnách hodnot
class ManagerGPS: NSObject, CLLocationManagerDelegate {

    
    
    // MARK - PROMĚNNÉ
    
    weak var delegate: WirelessManagerDelegate? // delegát s weak referencí
    private var locationManager: CLLocationManager? // manager který přijímá data
    private let uuid = UUID()

    

    // MARK: - FUNKCE
    
    /// Spustí sběr
    public func start() {

        locationManager = CLLocationManager()
        locationManager?.activityType = CLActivityType.fitness
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.delegate=self
        locationManager?.requestWhenInUseAuthorization()
    }
    
    /// Zastaví sběr dat
    func stop() {
        
        locationManager?.stopUpdatingLocation()
    }

    /// Požádání o aktuální souřadnice
    func requestLocation() {

        if locationManager?.location != nil {
            delegate?.gpsDataReceived(uuid: uuid, coordinates: locationManager!.location!.coordinate)
        }
        

    }
    
    
    
    // MARK: - DELEGÁTI CLLOCATION MANAGERA
    
    /// Odchytává změnu autorizace GPS zařízení
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            let newDevice = DataItemGPS(uuid: uuid)
            delegate?.deviceDidConnect(newDevice: newDevice)
            manager.startUpdatingLocation()
        }
    }
    
    /// Indikuje změnu lokace
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let lastValue = locations.last {
            delegate?.gpsDataReceived(uuid: uuid, coordinates: lastValue.coordinate)
        }
    }
 
}
