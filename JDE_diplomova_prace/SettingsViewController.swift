
import UIKit



/// Controller obsluhuje view pro nastavení aplikace
class SettingsViewController: UITableViewController, UITextFieldDelegate
{

    
    
    // MARK: - PROMĚNNÉ
    
  
    @IBOutlet weak var txtConfigFileURL: UITextField! // textfiled s adresou konfiguračního souboru
    @IBOutlet weak var labelCountDown: UILabel!     // label pro zobrazení aktuálně nastavené hodnoty odpočtu
    @IBOutlet weak var labelWalkingSpeedCorrection: UILabel! // label pro zobrazení aktuálně nastavené hodnoty korekce rychlosti chůze
    @IBOutlet weak var stepperWalkingSpeedCorrection: UIStepper! // stepper pro nastavení hodnoty korekce rychlosti chůze
    @IBOutlet weak var stepperCountDown: UIStepper! // stepper pro nastavení hodnoty odpočtu
    @IBOutlet weak var tableCellBluetooth: UITableViewCell!
    @IBOutlet weak var tableCellWifi: UITableViewCell!
    @IBOutlet weak var tableCellGPS: UITableViewCell!
    @IBOutlet weak var tableCellBTS: UITableViewCell!
    
    
    
    // MARK: - UDÁLOSTI
    
    override func viewDidLoad() {

        super.viewDidLoad()
        prepareForShow()
        txtConfigFileURL.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false //zobrazení tab baru
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        SettingsManager.sharedInstance.saveSettings()
    }
    
    /// Změna hodnoty ve stepperu (délka měření)
    @IBAction func stepperCountDown(_ sender: UIStepper) {
        
        SettingsManager.sharedInstance.countDown = Int(stepperCountDown.value)
        labelCountDown.text = String(SettingsManager.sharedInstance.countDown)
    }
    
    /// Změna hodnoty ve stepperu (korekce rychlosti chůze)
    @IBAction func stepperWalkingSpeedCorrection(_ sender: UIStepper) {
        
        SettingsManager.sharedInstance.walkingSpeedCorrection = Int(stepperWalkingSpeedCorrection.value)
        labelWalkingSpeedCorrection.text = String(SettingsManager.sharedInstance.walkingSpeedCorrection)
        
    }
    
    /// validace URL při dokončení editace v textfieldech
    @IBAction func txtConfigFileURLeditingDidEnd(_ sender: UITextField) {
        
        let url = URL(string: sender.text!) // zkusím vytvořit URL ze stringu v textfieldu
        
        if url == nil {
            // nevalidní URL - zobrazit upozornění
            let alert = UIAlertController(title: "Nevalidní URL", message: "Adresa není validní, zadejte správnou hodnotu.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
                sender.becomeFirstResponder()
            }))
        
            self.present(alert, animated: true, completion: nil)
        }
        else {
            // validní URL - uložit hodnotu do nastavení
            if sender == txtConfigFileURL { SettingsManager.sharedInstance.configFileURL = sender.text! }
        }
    }
    
    /// Stisknutí tlačítka reset pro vyvolání defaultního nastavení
    @IBAction func btnResetToDefaultTap(_ sender: Any) {
        
        // nevalidní URL - zobrazit upozornění
        let alert = UIAlertController(title: "Reset nastavení", message: "Chcete přepsat současné nastavení defaultními hodnotami?", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // akce Přepsat
        alert.addAction(UIAlertAction(title: "Přepsat", style: UIAlertActionStyle.destructive, handler: {(alert: UIAlertAction!) in
            SettingsManager.sharedInstance.resetToDefaults() // reset hodnot
            self.prepareForShow() // zobrazení nových hodnot
        }))
        
        // akce Zrušit
        alert.addAction(UIAlertAction(title: "Zrušit", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// schování klávesnice po skončení editace
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
    
    
    
    // MARK: - FUNKCE
    
    /// Nastavení uložených hodnot do UI
    private func prepareForShow() {
        
        stepperCountDown.value = Double(SettingsManager.sharedInstance.countDown)
        labelCountDown.text = String(SettingsManager.sharedInstance.countDown)
        stepperWalkingSpeedCorrection.value = Double(SettingsManager.sharedInstance.walkingSpeedCorrection)
        labelWalkingSpeedCorrection.text = String(SettingsManager.sharedInstance.walkingSpeedCorrection)
        txtConfigFileURL.text = SettingsManager.sharedInstance.configFileURL
        
        // nastavení zaškrtnutí u jednotlivých typů sítí
        if SettingsManager.sharedInstance.useBluetooth {tableCellBluetooth.accessoryType = UITableViewCellAccessoryType.checkmark} else {tableCellBluetooth.accessoryType = UITableViewCellAccessoryType.none}
        if SettingsManager.sharedInstance.useWiFi {tableCellWifi.accessoryType = UITableViewCellAccessoryType.checkmark} else {tableCellWifi.accessoryType = UITableViewCellAccessoryType.none}
        if SettingsManager.sharedInstance.useGPS {tableCellGPS.accessoryType = UITableViewCellAccessoryType.checkmark} else {tableCellGPS.accessoryType = UITableViewCellAccessoryType.none}
        if SettingsManager.sharedInstance.useBTS {tableCellBTS.accessoryType = UITableViewCellAccessoryType.checkmark} else {tableCellBTS.accessoryType = UITableViewCellAccessoryType.none}
    }
    


    // MARK: - DELEGÁTI TABULKY

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 5 // table view má 5 sekcí
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        switch section {
        case 0:
            // sekce 0 - nastavení URL
            return 1
        case 1:
            // sekce 1 - parametry měření
            return 4
        case 2:
            // sekce 2 - měření na místě
            return 1
        case 3:
            // sekce 3 - měření procházka
            return 1
        case 4:
            // sekce 2 - tlačítko reset
            return 1
        default:
            // defaultní sekce
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: indexPath)
            var isChecked:Bool?
            
            switch indexPath.row {
            case 0:
                // Bluetooth
                SettingsManager.sharedInstance.useBluetooth = !SettingsManager.sharedInstance.useBluetooth
                isChecked = SettingsManager.sharedInstance.useBluetooth
            case 1:
            // WiFi
                SettingsManager.sharedInstance.useWiFi = !SettingsManager.sharedInstance.useWiFi
                isChecked = SettingsManager.sharedInstance.useWiFi
            case 2:
            // GPS
                SettingsManager.sharedInstance.useGPS = !SettingsManager.sharedInstance.useGPS
                isChecked = SettingsManager.sharedInstance.useGPS
            case 3:
            // Mobilní síť
                SettingsManager.sharedInstance.useBTS = !SettingsManager.sharedInstance.useBTS
                isChecked = SettingsManager.sharedInstance.useBTS
            default:
                isChecked = false
            }
            
            if isChecked! { cell?.accessoryType = UITableViewCellAccessoryType.checkmark }
            else { cell?.accessoryType = UITableViewCellAccessoryType.none }
        }
    }
    
}
