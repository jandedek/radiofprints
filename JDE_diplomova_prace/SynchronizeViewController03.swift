
import UIKit



/// Controller obsluhuje třetí view pro synchronizaci dat (stav synchronizace)
class SynchronizeViewController03: UIViewController {


    
    // MARK: - PROMĚNNÉ
    
    public var couchID: String = ""
    private var btnBack: UIBarButtonItem?
    private var puller:CBLReplication?
    private var pusher:CBLReplication?
    private var totalUploaded:UInt32 = 0
    private var totalDownloaded:UInt32 = 0
    @IBOutlet weak var lblUpload: UILabel!
    @IBOutlet weak var lblDownload: UILabel!
    @IBOutlet weak var txtInfo: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnSync: UIBarButtonItem!
    
    
    
    // MARK: - UDÁLOSTI
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // skrytí defaultního tlačítka zpět a vytvoření vlastního
        self.navigationItem.setHidesBackButton(true, animated: true)
        btnBack = UIBarButtonItem(title: "Zpět", style: UIBarButtonItemStyle.plain, target: self, action: #selector(btnBackPressed(_:)))
        self.navigationItem.leftBarButtonItem = btnBack
        
        txtInfo.isHidden = false
        lblDownload.isHidden = true
        lblUpload.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true //schování tab baru
    }
    
    /// Postup stahování dat
    ///
    /// - Parameter notification: obdržená notifikace
    func pullProgress(notification: NSNotification) {
        
        if let tmpReplication = notification.object as? CBLReplication {
            objc_sync_enter(self)
            lblDownload.text = "Přijato \(tmpReplication.completedChangesCount)/\(tmpReplication.changesCount)"
            if !(puller?.running)! {
                lblDownload.textColor = UIColor.green
                puller?.stop()
            }
            totalDownloaded = tmpReplication.completedChangesCount
            objc_sync_exit(self)
        }
        if (puller?.status == CBLReplicationStatus.stopped || puller?.status == CBLReplicationStatus.idle) && (pusher?.status == CBLReplicationStatus.stopped || pusher?.status == CBLReplicationStatus.idle) {syncCompleted()}
    }
    
    /// Postup odesílání dat
    ///
    /// - Parameter notification: obdržená notifikace
    func pushProgress(notification: NSNotification) {
        
        if let tmpReplication = notification.object as? CBLReplication {
            
            objc_sync_enter(self)
            lblUpload.text = "Odesláno \(tmpReplication.completedChangesCount)/\(tmpReplication.changesCount)"
            if !(pusher?.running)! {
                lblUpload.textColor = UIColor.green
                pusher?.stop()
            }
            
            totalUploaded = tmpReplication.completedChangesCount
            objc_sync_exit(self)
        }
        if (puller?.status == CBLReplicationStatus.stopped || puller?.status == CBLReplicationStatus.idle) && (pusher?.status == CBLReplicationStatus.stopped || pusher?.status == CBLReplicationStatus.idle) {syncCompleted()}
    }
    
    /// Stisknutí tlačítka zpět (přesměrování na root view)
    ///
    /// - Parameter sender: objekt který vyvolal event
    @IBAction func btnBackPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "segueSynchronizeBackToRootNavigationController", sender: self)
    }
    
    /// Stisknutí tlačítka synchronizovat
    ///
    /// - Parameter sender: objekt který vyvolal event
    @IBAction func btnSyncPressed(_ sender: Any) {
        
        synchronizeData()
    }
    
    
    
    // MARK: - FUNKCE
    
    /// Zahájení synchronizace
    private func synchronizeData() {
    
        
        // úprava UI po spuštění synchronizace
        lblDownload.text = ""
        lblUpload.text = ""
        lblDownload.textColor = UIColor.black
        lblUpload.textColor = UIColor.black
        activityIndicator.startAnimating()
        
        btnBack?.isEnabled = false
        btnSync.isEnabled = false
        txtInfo.isHidden = true
        lblDownload.isHidden = false
        lblUpload.isHidden = false
        
        let dbName = SettingsManager.sharedInstance.localDbName
        var localDatabase: CBLDatabase?
        
        do  { localDatabase = try CBLManager.sharedInstance().databaseNamed(dbName) } // získá uloženou databázi nebo vytvoří prázdnou
        catch let error {
            // nevalidní URL - zobrazit upozornění
            let alert = UIAlertController(title: "Chyba", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: {self.performSegue(withIdentifier: "segueSynchronizeBackToRootNavigationController", sender: self)}) // zobrazit alert a zpět na root view
        }
        
        if localDatabase != nil {
            
            DataHolder.signData(couchID: couchID)
            let dbURL = URL(string: SettingsManager.sharedInstance.gatewayURL)
            puller = localDatabase!.createPullReplication(dbURL!)
            pusher = localDatabase!.createPushReplication(dbURL!)
 
            puller?.continuous = false
            pusher?.continuous = false
            
            NotificationCenter.default.addObserver(self, selector: #selector(pullProgress(notification:)), name: NSNotification.Name.cblReplicationChange, object: puller)
            NotificationCenter.default.addObserver(self, selector: #selector(pushProgress(notification:)), name: NSNotification.Name.cblReplicationChange, object: pusher)

            puller?.start()
            pusher?.start()
        }
    }
    
    /// Synchronizace dokončena
    private func syncCompleted() {
    
        objc_sync_enter(self)
        btnBack?.isEnabled = true
        btnSync.isEnabled = true
        activityIndicator.stopAnimating()
        objc_sync_exit(self)
        
        let alert = UIAlertController(title: "Synchronizace dokončena", message: "Vaše zařízená je nyní synchronizované se vzdáleným serverem", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: {self.performSegue(withIdentifier: "segueSynchronizeBackToRootNavigationController", sender: self)}) // zobrazit alert a zpět na root view
    }

}
