import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = gradientGenerator.generateImage(c1: c1, c2: c2, c3: c3, c4: c4)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func click(_ sender: Any) {
        if isAnimating {
            return
        }
        
        startAnimation()
        shuffle()
    }
    
    let fps = 30
    let size = UIScreen.main.bounds.width / 20
    
    let pixels = PixelsData(
        pixel1: PixelData(a: 255, r: 136, g: 163, b: 133),
        pixel2: PixelData(a: 255, r: 253, g: 245, b: 203),
        pixel3: PixelData(a: 255, r: 65, g: 109, b: 86),
        pixel4: PixelData(a: 255, r: 247, g: 228, b: 140)
    )
    
    /*let pixels = PixelsData(
        pixel1: PixelData(a: 255, r: 255, g: 0, b: 255),
        pixel2: PixelData(a: 255, r: 0, g: 255, b: 255),
        pixel3: PixelData(a: 255, r: 0, g: 0, b: 0),
        pixel4: PixelData(a: 255, r: 255, g: 255, b: 0)
    )*/
    
    /*
    lazy var c1 = CGPoint(x: size, y: 0)
    lazy var c2 = CGPoint(x: 0, y: 0)
    lazy var c3 = CGPoint(x: 0, y: size)
    lazy var c4 = CGPoint(x: size, y: size)
    */
    
    lazy var c1 = CGPoint(x: size * 3 / 5, y: size * 3 / 20)
    lazy var c2 = CGPoint(x: size / 4, y: size * 3 / 5)
    lazy var c3 = CGPoint(x: size - size * 3 / 5, y: size - size * 3 / 20)
    lazy var c4 = CGPoint(x: size - size / 4, y: size - size * 3 / 5)
    
    lazy var c12 = CGPoint(x: size * 7 / 20, y: size * 3 / 10)
    lazy var c23 = CGPoint(x: size - size * 4 / 5, y: size - size / 10)
    lazy var c34 = CGPoint(x: size - size * 7 / 20, y: size - size * 3 / 10)
    lazy var c41 = CGPoint(x: size * 4 / 5, y: size / 10)
 
    lazy var gradientGenerator = GradientGenerator(size: size, pixels: pixels)
    lazy var animationCreator = AnimationCreator(
        gradientGenerator: gradientGenerator,
        fps: fps
    )
    
    var isAnimating = false
    
    func startAnimation() {
        
        isAnimating = true
                
        let animationData = AnimationData(
            start1: c1,
            start2: c2,
            start3: c3,
            start4: c4,
            end1: c12,
            end2: c23,
            end3: c34,
            end4: c41
        )
                
        var images = animationCreator.createAnimation(animationData: animationData).images
        var buffer = [UIImage]()
                    
        var i = 0
        
        var isFinished = false
                
        let timer = Timer.scheduledTimer(withTimeInterval: 1 / Double(fps), repeats: true) { [weak self] timer in
            if i >= images.count {
                images = buffer
                buffer = []
                self?.animationCreator.imagesRequired = true
                i = 0
            }
            
            if i < images.count {
                self?.imageView.image = images[i]
                
                i += 1
            } else if isFinished {
                timer.invalidate()
                self?.isAnimating = false
                return
            }
        }
        
        animationCreator.startAnimating(animationData: animationData) { (imgs) in
            buffer = imgs
        } completed: {
            isFinished = true
        }
        
        timer.fire()
    }
    
    func shuffle() {
        let c0 = c1
        c1 = c12
        c12 = c2
        c2 = c23
        c23 = c3
        c3 = c34
        c34 = c4
        c4 = c41
        c41 = c0
    }
}
