import Foundation
import UIKit

struct AnimationData {
    let start1: CGPoint
    let start2: CGPoint
    let start3: CGPoint
    let start4: CGPoint
    let end1: CGPoint
    let end2: CGPoint
    let end3: CGPoint
    let end4: CGPoint
}

struct PixelsData {
    let pixel1: PixelData
    let pixel2: PixelData
    let pixel3: PixelData
    let pixel4: PixelData
}

struct AnimationResultData {
    let images: [UIImage]
    let animationFinished: Bool
}

class AnimationCreator {
    
    init(gradientGenerator: GradientGenerator, fps: Int) {
        self.generator = gradientGenerator
        self.fps = CGFloat(fps)
        self.totalIterations = fps / 10
    }
    
    private let generator: GradientGenerator
    private let fps: CGFloat
    private let totalIterations: Int
    
    private var currentIteration: CGFloat = 0
    
    private func generateImages(animationData: AnimationData) -> [UIImage] {
                        
        let d1x = (animationData.end1.x - animationData.start1.x) / fps
        let d1y = (animationData.end1.y - animationData.start1.y) / fps
        let d2x = (animationData.end2.x - animationData.start2.x) / fps
        let d2y = (animationData.end2.y - animationData.start2.y) / fps
        let d3x = (animationData.end3.x - animationData.start3.x) / fps
        let d3y = (animationData.end3.y - animationData.start3.y) / fps
        let d4x = (animationData.end4.x - animationData.start4.x) / fps
        let d4y = (animationData.end4.y - animationData.start4.y) / fps
        
        var c1 = CGPoint(
            x: animationData.start1.x + d1x * currentIteration * 10,
            y: animationData.start1.y + d1y * currentIteration * 10
        )
        var c2 = CGPoint(
            x: animationData.start2.x + d2x * currentIteration * 10,
            y: animationData.start2.y + d2y * currentIteration * 10
        )
        var c3 = CGPoint(
            x: animationData.start3.x + d3x * currentIteration * 10,
            y: animationData.start3.y + d3y * currentIteration * 10
        )
        var c4 = CGPoint(
            x: animationData.start4.x + d4x * currentIteration * 10,
            y: animationData.start4.y + d4y * currentIteration * 10
        )
                
        var images = [UIImage]()
        
        for _ in 0..<10 {
            
            c1 = CGPoint(x: c1.x + d1x, y: c1.y + d1y)
            c2 = CGPoint(x: c2.x + d2x, y: c2.y + d2y)
            c3 = CGPoint(x: c3.x + d3x, y: c3.y + d3y)
            c4 = CGPoint(x: c4.x + d4x, y: c4.y + d4y)

            if let image = generator.generateImage(
                c1: c1,
                c2: c2,
                c3: c3,
                c4: c4
            ) {
                images.append(image)
            }
        }
        currentIteration += 1
        return images
    }
    
    func createAnimation(animationData: AnimationData) -> AnimationResultData {
        let images = generateImages(animationData: animationData)
        
        let res: Bool
        if Int(currentIteration) >= totalIterations {
            currentIteration = 0
            res = true
        } else {
            res = false
        }
        
        return AnimationResultData(images: images, animationFinished: res)
    }
    
    var imagesRequired = true
    
    func startAnimating(animationData: AnimationData, returnImages: @escaping ([UIImage]) -> Void, completed: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            while true {
                if self.imagesRequired {
                    self.imagesRequired = false
                    let result = self.createAnimation(animationData: animationData)
                    returnImages(result.images)
                    if result.animationFinished {
                        break
                    }
                }
            }
            completed()
        }
    }
}
