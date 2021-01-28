import Foundation
import UIKit

class Geometry {
    
    static var distances = [Poent : CGFloat]()

    class func distance(x: CGFloat, y: CGFloat) -> CGFloat {
        
        let poent = Poent(x: x, y: y)
        let altPoent = Poent(x: y, y: x)
        
        if let saved = distances[poent] {
            return saved
        } else if let saved = distances[altPoent] {
            return saved
        }
        
        let calculated = sqrt(x * x + y * y)
        distances[poent] = calculated
        distances[altPoent] = calculated

        return calculated
    }
    
    
}
