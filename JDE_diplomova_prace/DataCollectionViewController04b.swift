
import UIKit



/// Controller obsluhuje view pro sběr dat - měření na místě (výběr místa na mapě)
class DataCollectionViewController04b: UIViewController, UIWebViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    
    
    // MARK: - PROMĚNNÉ
    
    @IBOutlet var mapWebView: UIWebView!
    @IBOutlet weak var labelCoord: UILabel!
    @IBOutlet var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet weak var webActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonStart: UIBarButtonItem!
    private var lastScaleValue: CGFloat = 1.0 // pomocná proměnná která udržuje hodnotu přiblížení mezi gesty
    public var mapURL:URL?
    public var mapID: String?
    public var currentCoords: CGPoint? // aktuální souřadnice
    
    
    
    // MARK: - UDÁLOSTI
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapWebView.delegate = self
        mapWebView.scrollView.delegate = self // detekce scrollování (= změna souřadnic)
        pinchGestureRecognizer.delegate=self
    }

    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true //schování tab baru
        
        if mapURL != nil {
            mapWebView.loadRequest(URLRequest(url: mapURL!)) // adresa je ok
        }
        else {
            // nevalidní URL - zobrazit upozornění
            let alert = UIAlertController(title: "Nevalidní URL mapy", message: "Mapa není k dispozici", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    /// Dokončení scrollování - skončení animace (získání a vypsání souřadnic)
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        //let currentCoords = getCoordinates()
        currentCoords = getCoordinates()
        labelCoord.text = "X:\(Int(currentCoords!.x)) Y:\(Int(currentCoords!.y))"
    }
    
    /// Dokončení scrollování - odstranění prstu z obrazovky (získání a vypsání souřadnic)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        currentCoords = getCoordinates()
        labelCoord.text = "X:\(Int(currentCoords!.x)) Y:\(Int(currentCoords!.y))"
    }
    
    /// Příprava view s mapou předtím, než je samotný view zobrazen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "segueCollectDataProgress" {
            
            let destinationView = segue.destination as? DataCollectionViewController05b
            
            if destinationView != nil {
                
                destinationView?.mapID = mapID!
                destinationView?.mapCoord = getCoordinates()
            }
        }
    }
    
    
    
    // MARK: - FUNKCE
    
    /// Pomocí javascript funkce získá aktuální souřadnice a vrátí je jako CGPoint
    private func getCoordinates() -> CGPoint {
        
        // získání dat jako NSString (narozdíl od stringu poskytuje metody pro konverzi na číselné typy)
        let strPositionX = NSString(string: mapWebView.stringByEvaluatingJavaScript(from: "getCrosshairLogicX()")!)
        let strPositionY = NSString(string: mapWebView.stringByEvaluatingJavaScript(from: "getCrosshairLogicY()")!)
        let currentPoint = CGPoint(x: strPositionX.doubleValue, y: strPositionY.doubleValue)

        return currentPoint
    }

    /// Nastavení mapy na požadované souřadnice
    private func setCoordinates() {
        
        if currentCoords != nil {
            let x: Int = Int(currentCoords?.x ?? 0)
            let y: Int = Int(currentCoords?.y ?? 0)
            mapWebView.stringByEvaluatingJavaScript(from: "scrollToLogicXY(\(x), \(y))") // nastavení pozice mapy
        }
    }

    
    // MARK: - DELEGÁTI WEB VIEW
    
    /// webView začal načítat stránku
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        lastScaleValue = 1.0 // každá nově načtená stránka má scale = 1 (bez přiblížení nebo oddálení)
        webActivityIndicator.startAnimating()
        labelCoord.isHidden = true
        buttonStart.isEnabled = false
    }
    
    /// po načtení stránky zjistit aktuální souřadnice
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        mapWebView.stringByEvaluatingJavaScript(from: "document.getElementById('zoom-in').hidden='hidden';") // skrytí tlačítka zoom-in
        mapWebView.stringByEvaluatingJavaScript(from: "document.getElementById('zoom-out').hidden='hidden';")// skrytí tlačítka zoom-out
        

        setCoordinates()

        currentCoords = getCoordinates()
        labelCoord.text = "X:\(Int(currentCoords!.x)) Y:\(Int(currentCoords!.y))" // vypsání aktuálních souřadnic

        labelCoord.isHidden = false
        buttonStart.isEnabled = true
        webActivityIndicator.stopAnimating()
    }
    
    /// chyba při načítání stránky
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        print("didFailLoadWithError: \(error.localizedDescription)")
        
        webActivityIndicator.stopAnimating()
        
        // nevalidní URL - zobrazit upozornění
        let alert = UIAlertController(title: "Otevírání stránky selhalo", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// změna velikosti nebo orientace view - refresh stránky s mapou
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        mapWebView.reload()
    }
    
    /// rospoznání gesta Pinch (zoom stránky)
    @IBAction func gestureDidUse(_ sender: UIPinchGestureRecognizer) {
        
        let minScale: CGFloat = 0.5 // spodní hranice zoomu
        let maxScale: CGFloat = 1.5 // horní hranice zoomu

        // nastavení hranic zoomu
        if sender.scale < minScale {sender.scale = minScale}
        else if sender.scale > maxScale {sender.scale = maxScale}
        
        // pokud se hodnota zoomu nezměnila o víc než 0.025 oproti volání, ve kterém se naposledy provedl zoom, je funkce ukončena
        // (tímto omezením je nastavena citlivost zoomu)
        if abs(lastScaleValue - sender.scale) < 0.025 {return}
        
        // rozlišení zda se jedná o přiblížení nebo oddálení a kontrola zda velikost přiblížení není mimo povolenou hranici
        // sender.velocity < 0 = oddálení
        // sender.velocity > 0 = přiblížení
        if sender.velocity < 0 && sender.scale > minScale {
            mapWebView.stringByEvaluatingJavaScript(from: "document.getElementById('zoom-out').click();") // zavolání eventu "click" tlačítka zoom-out
        }
        else if sender.velocity > 0 && sender.scale < maxScale {
            mapWebView.stringByEvaluatingJavaScript(from: "document.getElementById('zoom-in').click();") // zavolání eventu "click" tlačítka zoom-in
        }

        lastScaleValue = sender.scale
    }

    /// začátek nového gesta
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // na začátku nového gesta se doplní poslední scale hodnota.
        // Tato funkce je zde proto, že si UIPinchGestureRecognizer nepamatuje stav mezi jednotlivými gesty
        // a díky tomu je možné obejít min a max hranici přiblížení (pokud toto není ošetřeno na úrovni javascriptu)
        if let pinchGesture = gestureRecognizer as? UIPinchGestureRecognizer {
            pinchGesture.scale = lastScaleValue
        }

        return false
    }

}
