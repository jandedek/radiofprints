
import UIKit



/// Controller obsluhuje třetí view pro náhled naměřených hodnot (mapa s označením kde proběhlo měření)
class ShowDataViewController03Map: UIViewController, UIWebViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    
    // MARK: - PROMĚNNÉ
    
    @IBOutlet weak var mapWebView: UIWebView!
    @IBOutlet weak var webActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var pinchGestureRecognizer: UIPinchGestureRecognizer!
    public var mapURL: URL?
    public var mapCoord: CGPoint?
    private var lastScaleValue: CGFloat = 1.0 // pomocná proměnná která udržuje hodnotu přiblížení mezi gesty
 

 
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
    


    // MARK: - DELEGÁTI WEB VIEW
    
    /// Po dokončení scrollování nastavit zpět souřadnice kde probíhalo měření
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let x: Int = Int(mapCoord?.x ?? 0)
        let y: Int = Int(mapCoord?.y ?? 0)
        mapWebView.stringByEvaluatingJavaScript(from: "scrollToLogicXY(\(x), \(y))") // nastavení pozice mapy
    }
    
    /// webView začal načítat stránku
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        lastScaleValue = 1.0 // každá nově načtená stránka má scale = 1 (bez přiblížení nebo oddálení)
        webActivityIndicator.startAnimating()
    }
    
    /// po načtení stránky zjistit aktuální souřadnice
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        mapWebView.stringByEvaluatingJavaScript(from: "document.getElementById('zoom-in').hidden='hidden';") // skrytí tlačítka zoom-in
        mapWebView.stringByEvaluatingJavaScript(from: "document.getElementById('zoom-out').hidden='hidden';") // skrytí tlačítka zoom-out
        
        let x: Int = Int(mapCoord?.x ?? 0)
        let y: Int = Int(mapCoord?.y ?? 0)
        mapWebView.stringByEvaluatingJavaScript(from: "scrollToLogicXY(\(x), \(y))") // nastavení pozice mapy

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
        // a díky tomu je je možné obejít min a max hranici přiblížení (pokud toto není ošetřeno na úrovni javascriptu)
        if let pinchGesture = gestureRecognizer as? UIPinchGestureRecognizer {
            pinchGesture.scale = lastScaleValue
        }
        
        return false
    }
       
}
