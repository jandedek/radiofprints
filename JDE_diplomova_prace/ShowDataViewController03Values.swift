
import UIKit



/// Controller obsluhuje třetí view pro náhled naměřených hodnot (detail naměřených hodnot)
class ShowDataViewController03Values: UITableViewController {


    
    // MARK: - PROMĚNNÉ
    
    /// Naměřená data k zobrazení
    public var collectedData: DataHolder?
    
    /// Data k mapě
    public var mapData: (location: String, description: String, mapURL: URL, mapID: String)?
    
    
    
    // MARK: - UDÁLOSTI
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true //schování tab baru
    }
    
    /// Příprava view s mapou předtím, než je samotný view zobrazen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "segueShowDataDetailBleScan" {
            // zobrazení bluetooth
            if let destinationView = segue.destination as? ShowDataViewController04Ble {
                for device in (collectedData?.getBleData())! {
                    for value in device.listOfValues  {
                        destinationView.collectedData.append((address: device.address, name: device.deviceName, rssi: value.rssi, elapsedTime: value.elapsedTime))
                        print("minor: \(device.minor) major: \(device.major)")
                    }
                }
                destinationView.collectedData = destinationView.collectedData.sorted(by: {$0.0.elapsedTime < $0.1.elapsedTime}) // seřazení pole vzestupně podle času měření
            }
        }
        else if segue.identifier == "segueShowDataDetailGpsScan" {
            // zobrazení GPS
            if let destinationView = segue.destination as? ShowDataViewController04Gps {
                if let device = collectedData?.getGpsData() {
                    for value in device.listOfValues {
                        destinationView.collectedData.append((location: value.coordinates, elapsedTime: value.elapsedTime))
                    }
                    destinationView.collectedData = destinationView.collectedData.sorted(by: {$0.0.elapsedTime < $0.1.elapsedTime}) // seřazení pole vzestupně podle času měření
                }
            }
        }
    }
    
    
    
    // MARK: - DELEGÁTI TABLE VIEW
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 18
        case 1:
            if (collectedData?.collectBtsData == true) {return 6} else {return 1}
        case 2:
            if (collectedData?.collectWifiData == true) {return 2} else {return 1}
        case 3:
            return 1
        case 4:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "Informace o měření"
            
        case 1:
            return "Mobilní data"
            
        case 2:
            return "WiFi scan"
            
        case 3:
            return "Bluetooth scan"
            
        case 4:
            return "Geolokační data"
            
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell?
        var name: String?
        var value: String?
        
        // formát data a času
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        formatter.timeStyle = DateFormatter.Style.medium
    

        if indexPath.section == 0 {
            
            // ***** informace o měření *****
            
            cell = tableView.dequeueReusableCell(withIdentifier: "PrototypeCellShowDataDetail", for: indexPath)
            cell!.accessoryType = UITableViewCellAccessoryType.none
            
            switch indexPath.row {
            case 0:
                name = "ID uživatele"
                value = collectedData?.userID
            case 1:
                name = "Lokalita"
                value = mapData?.location
                
            case 2:
                name = "Upřesnění místa"
                value = mapData?.description
                
            case 3:
                name = "ID mapy"
                value = collectedData?.level
                
            case 4:
                name = "Souřadnice na mapě"
                if (collectedData?.mapX != nil && collectedData?.mapY != nil) {value = "X:\(collectedData!.mapX!) | Y:\(collectedData!.mapY!)"}
                
            case 5:
                name = "Začátek měření"
                if (collectedData?.collectStartTime != nil) {value = formatter.string(from: collectedData!.collectStartTime!)}
                
            case 6:
                name = "Konec měření"
                if (collectedData?.collectEndTime != nil) {value = formatter.string(from: collectedData!.collectEndTime!)}
                
            case 7:
                name = "ID zařízení"
                value = collectedData?.deviceID
                
            case 8:
                name = "Hardware"
                value = collectedData?.model
                
            case 9:
                name = "Operační systém"
                if (collectedData?.systemName != nil && collectedData?.systemVersion != nil) {value = "\(collectedData!.systemName!) \(collectedData!.systemVersion!)"}
                
            case 10:
                name = "Stav baterie"
                if (collectedData?.batteryLevel != nil) {value = "\(collectedData!.batteryLevel!)"}
                
            case 11:
                name = "Napájecí režim"
                value = collectedData?.batteryState
                
            case 12:
                name = "Gyroskop"
                if (collectedData?.gyroX != nil && collectedData?.gyroY != nil && collectedData?.gyroZ != nil) {value = String(format: "X: %.5f | Y: %.5f | Z: %.5f", collectedData!.gyroX!, collectedData!.gyroY!, collectedData!.gyroZ! )}
            case 13:
                name = "Magnetometr"
                if (collectedData?.magnetoX != nil && collectedData?.magnetoY != nil && collectedData?.magnetoZ != nil) {value = String(format: "X: %.5f | Y: %.5f | Z: %.5f", collectedData!.magnetoX!, collectedData!.magnetoY!, collectedData!.magnetoZ! )}
                
            case 14:
                name = "Sběr Bluetooth dat"
                if (collectedData?.collectBluetoothData != nil) {
                    if (collectedData?.collectBluetoothData == true) {cell!.accessoryType = UITableViewCellAccessoryType.checkmark}
                    value = ""
                }
                
            case 15:
                name = "Sběr WiFi dat"
                if (collectedData?.collectWifiData != nil) {
                    if (collectedData?.collectWifiData == true) {cell!.accessoryType = UITableViewCellAccessoryType.checkmark}
                    value = ""
                }
                
            case 16:
                name = "Sběr mobilních dat"
                if (collectedData?.collectBtsData != nil) {
                    if (collectedData?.collectBtsData == true) {cell!.accessoryType = UITableViewCellAccessoryType.checkmark}
                    value = ""
                }
                
            case 17:
                name = "Sběr geolokačních dat"
                if (collectedData?.collectGpsData != nil) {
                    if (collectedData?.collectGpsData == true) {cell!.accessoryType = UITableViewCellAccessoryType.checkmark}
                    value = ""
                }
                
            default:
                break
                
            }
            
        }
        else if indexPath.section == 1 {
            
            // ***** mobilní data *****
            
            cell = tableView.dequeueReusableCell(withIdentifier: "PrototypeCellShowDataDetail", for: indexPath)
            cell!.accessoryType = UITableViewCellAccessoryType.none
            
            
            if (collectedData?.collectBtsData == true) {
                
                let dataItemBTS = collectedData?.getMobileData()
                
                switch indexPath.row {
                case 0:
                    name="Technologie"
                    value = dataItemBTS?.currentRadioAccessTechnology
                    
                case 1:
                    name="Poskytovatel"
                    value = dataItemBTS?.carrierName
                    
                case 2:
                    name="ISO"
                    value = dataItemBTS?.isoCountryCode
                    
                case 3:
                    name="MCC"
                    value = dataItemBTS?.mobileCountryCode
                    
                case 4:
                    name="MNC"
                    value = dataItemBTS?.mobileNetworkCode
                    
                case 5:
                    name="Povoleno VOIP"
                    if (dataItemBTS?.allowsVOIP != nil) {
                        if (dataItemBTS?.allowsVOIP == true) {cell!.accessoryType = UITableViewCellAccessoryType.checkmark}
                        value = ""
                    }
                    
                default:
                    break
                }
            }
            else {
                name = ""
                value = "-"
            }
        }
        else if indexPath.section == 2 {
            
            // ***** wifi scan *****
            
            cell = tableView.dequeueReusableCell(withIdentifier: "PrototypeCellShowDataDetail", for: indexPath)
            cell!.accessoryType = UITableViewCellAccessoryType.none
            
            if (collectedData?.collectWifiData == true) {
                
                let dataItemWifi = collectedData?.getWifiData()
                
                switch indexPath.row {
                case 0:
                    name="SSID"
                    value = dataItemWifi?.SSID
                    
                case 1:
                    name="BSSID"
                    value = dataItemWifi?.BSSID
                default:
                    break
                }
            }
            else {
                name = ""
                value = "-"
            }

        }
        else if indexPath.section == 3 {
            
            // ***** bluetooth scan *****
            
            cell = tableView.dequeueReusableCell(withIdentifier: "PrototypeCellShowDataDetailBle", for: indexPath)
            
            if (collectedData?.collectBluetoothData == true) {
                
                cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                cell?.isUserInteractionEnabled = true
                name = "Naměřené hodnoty"
                value = ""
                
            }
            else {
                
                cell!.accessoryType = UITableViewCellAccessoryType.none
                cell?.isUserInteractionEnabled = false
                name = ""
                value = "-"
            }

        }
        else if indexPath.section == 4 {
            
            // ***** geolokační data *****
            
            cell = tableView.dequeueReusableCell(withIdentifier: "PrototypeCellShowDataDetailGps", for: indexPath)
            
            if (collectedData?.collectGpsData == true) {
                
                cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                cell?.isUserInteractionEnabled = true
                name = "Naměřené hodnoty"
                value = ""
                
            }
            else {
                
                cell!.accessoryType = UITableViewCellAccessoryType.none
                cell?.isUserInteractionEnabled = false
                name = ""
                value = "-"
            }
            
        }
        

        cell!.textLabel?.text = name ?? "-"
        cell!.detailTextLabel?.text = value ?? "-"
        return cell!
        
    }

}
