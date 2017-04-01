
import UIKit
import Foundation



/// Třída udržuje seznam načtených bodů, kterými má uživatel projít při měření typu "procházka".
/// Třída zároveň dopočítává všechny body, které jsou  mezi dvěma zadanými souřadnicemi
class WalkingPointsGenerator: NSObject {
    
    
    
    // MARK: - PROMĚNNÉ
    
    public var listOfWalkingPoints = [(x: Int, y: Int)]()   // seznam bodů kterými uživatel bude procházet
    private var currentPoint: (x: Double, y: Double)?       // aktuálně nastavený bod
    
    
    
    /// Konstruktor třídy
    init(walkingPoints : [(x: Int, y: Int)]?) {
       
        listOfWalkingPoints = walkingPoints ?? [(x: Int, y: Int)]()
        
        // pokud se v seznamu nacházejí alespoň dva body, nastavit currentPoint na první bod ze seznamu a nextFixedPoint na druhý bod ze seznamu
        if listOfWalkingPoints.count > 1 {
            currentPoint = (x: Double(listOfWalkingPoints[0].x), y: Double(listOfWalkingPoints[0].y))
        }
    }

    

    /// Funkce vygeneruje následující bod. Pokud další bod není k dispozici (procházka je na svém konci) je vráceno nil
    ///
    /// - Returns: souřadnice x a y. collectData značí průchod bodem ve kterém má proběhnout nové měření (true)
    public func getNextPoint() -> (x: Int, y: Int)? {
        
        if listOfWalkingPoints.count == 0 {
            
            currentPoint = nil // procházka ukončena
        }
        else {

            // výpočet vzdálenost dvou bodů a úhlu v radiánech který svírají s osou X
            let deltaX = Double(listOfWalkingPoints[0].x) - currentPoint!.x
            let deltaY = Double(listOfWalkingPoints[0].y) - currentPoint!.y
            let angleInRad = atan2(deltaY, deltaX)
            
            // výpočet následujícího bodu
            // 1.0 značí délku kroku, zde se pohybujeme o 1 mapový bod
            // v tomto případě je tato konstanta zbytečná, je zde pouze pro demonstraci
            currentPoint!.y += sin(angleInRad) * 1.0
            currentPoint!.x += cos(angleInRad) * 1.0

            // pokud je aktuální pozice 3 body v okolí bodu kterým se má projít je vytyčen další bod
            if abs(deltaX) < 3.0 && abs(deltaY) < 3.0 {
                
                currentPoint = (x: Double(listOfWalkingPoints[0].x), y: Double(listOfWalkingPoints[0].y))
                listOfWalkingPoints.removeFirst()
            }
        }
        
        if currentPoint == nil {return nil}
        else {
            return (x: Int(currentPoint!.x), y: Int(currentPoint!.y))
        }
        
    }
    
    
    /// Funkce vrátí první bod, na kterém uživatel bude začínat měření. Pokud žádný body není k dispozici (kolekce je prázdná) vrátí se nil
    ///
    /// - Returns: souřadnice aktuálně nastaveného bodu
    public func getCurrentPoint() -> (x: Int, y: Int)? {

        return (x: Int(currentPoint!.x), y: Int(currentPoint!.y))
    }

}
