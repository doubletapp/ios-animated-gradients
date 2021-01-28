import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var gradientView: GradientView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        gradientView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: gradientView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: gradientView.rightAnchor),
            imageView.topAnchor.constraint(equalTo: gradientView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor),
        ])
        
        imageView.contentMode = .scaleToFill
        gradientView.imageView = imageView
        
        gradientView.setImage(image: gradientView.generateImage())
        
        DispatchQueue.global().async { [weak self] in
            self?.animate()
        }
    }
    
    func animate() {
        let images1 = gradientView.generateImages(ticks: 100)
        let images2 = gradientView.generateImages(ticks: 100)
        let images3 = gradientView.generateImages(ticks: 100)
        let images4 = gradientView.generateImages(ticks: 100)
        
        DispatchQueue.main.async { [weak self] in
            let image = UIImage.animatedImage(with: images1 + images2 + images3 + images4, duration: 5)
            
            self?.gradientView.imageView.animationRepeatCount = 1
            self?.gradientView.imageView.image = image
        }
    }
}
