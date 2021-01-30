import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        startTimer()
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    let fps = 60
    
    let c = PixelData(a: 255, r: 0, g: 255, b: 255)
    let m = PixelData(a: 255, r: 255, g: 0, b: 255)
    let y = PixelData(a: 255, r: 255, g: 255, b: 0)
    let k = PixelData(a: 255, r: 0, g: 0, b: 0)
    
    func startTimer() {
        
        let size = UIScreen.main.bounds.width / 20
        
        
        
        var c1 = CGPoint(x: size, y: 0)
        var c2 = CGPoint(x: 0, y: 0)
        var c3 = CGPoint(x: 0, y: size)
        var c4 = CGPoint(x: size, y: size)
        
        let animationCreator = AnimationCreator(
            size: size,
            pixels: PixelsData(
                pixel1: m,
                pixel2: c,
                pixel3: k,
                pixel4: y
            ),
            fps: fps
        )
        
        var animationData = AnimationData(
            start1: c1,
            start2: c2,
            start3: c3,
            start4: c4,
            end1: c2,
            end2: c3,
            end3: c4,
            end4: c1
        )
        
        let fps = self.fps
        
        var images = animationCreator.createAnimation(animationData: animationData).images
        var buffer = animationCreator.createAnimation(animationData: animationData).images
                    
        var i = 0
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1 / Double(fps), repeats: true) { [weak self] timer in
            
            if i >= images.count {
                images = buffer
                buffer = []
                i = 0
            }
            
            if i < images.count {
                self?.imageView.image = images[i]
                
                i += 1
            }
        }
        
        DispatchQueue.global().async {
            while true {
                if buffer.count == 0 {
                    let result = animationCreator.createAnimation(animationData: animationData)
                    buffer = result.images
                    if result.animationFinished {
                        Self.shuffle(c1: &c1, c2: &c2, c3: &c3, c4: &c4, animationData: &animationData)
                    }
                }
            }
        }
        
        timer.fire()
    }
    
    class func nextAnimation(c1: CGPoint, c2: CGPoint, c3: CGPoint, c4: CGPoint) -> AnimationData {
        let c1New = c2
        let c2New = c3
        let c3New = c4
        let c4New = c1
        
        return AnimationData(
            start1: c1New,
            start2: c2New,
            start3: c3New,
            start4: c4New,
            end1: c2New,
            end2: c3New,
            end3: c4New,
            end4: c1New
        )
    }
    
    class func shuffle(c1: inout CGPoint, c2: inout CGPoint, c3: inout CGPoint, c4: inout CGPoint, animationData: inout AnimationData) {
        let c0 = c1
        c1 = c2
        c2 = c3
        c3 = c4
        c4 = c0
        
        animationData = AnimationData(
            start1: c1,
            start2: c2,
            start3: c3,
            start4: c4,
            end1: c2,
            end2: c3,
            end3: c4,
            end4: c1
        )
    }
}
