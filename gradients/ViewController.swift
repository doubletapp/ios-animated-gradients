import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var gradientView: GradientView!
    
    @IBAction func click(_ sender: Any) {
        
        gradientView.c1 = CGPoint(x: 270, y: 150)
        gradientView.c2 = CGPoint(x: 100, y: 650)
        
        gradientView.xDiffs = [:]
        gradientView.yDiffs = [:]
        
        gradientView.setNeedsDisplay()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
