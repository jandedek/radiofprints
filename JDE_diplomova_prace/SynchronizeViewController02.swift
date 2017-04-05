
import UIKit



/// Controller obsluhuje druhý view pro synchronizaci dat (login uživatele)
class SynchronizeViewController02: UIViewController, UIWebViewDelegate {

    
    
    // MARK: - PROMĚNNÉ
    
    @IBOutlet weak var webViewAuth: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var couchID: String = ""
    
    
    
    // MARK: - UDÁLOSTI

    override func viewDidLoad() {
        
        super.viewDidLoad()
        webViewAuth.delegate = self
        logIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true //schování tab baru
    }
    
    /// Příprava view s mapou předtím, než je samotný view zobrazen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueSynchronizeLogged" {
            
            let destinationView = segue.destination as? SynchronizeViewController03
            
            if destinationView != nil {
                destinationView?.couchID = couchID
            }
        }
    }
    
    
    
    // MARK: - FUNKCE
    
    /// Login aplikace do Google služby
    func logIn() {
        
        let url = URL(string: SettingsManager.sharedInstance.loginURL)
        
        if url != nil {
            let request = URLRequest(url: url!)
            webViewAuth.loadRequest(request)
        }
        else {
            let alert = UIAlertController(title: "Chyba", message: "Nevalidní URL autentizační služby", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }

    
    
    // MARK: - DELEGÁTI WEB VIEW
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
       activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        couchID = (NSString(string: webViewAuth.stringByEvaluatingJavaScript(from: "document.getElementById('couchId').value")!) as String).lowercased()
        activityIndicator.stopAnimating()
        
        // pokdud couchID začíné prefixem "google" pokračovat dál
        if couchID.hasPrefix("google") {
               self.performSegue(withIdentifier: "segueSynchronizeLogged", sender: self)
        }
    }
    
}
