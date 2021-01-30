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
    
    static let framesPerGeneration = 10
    
    init(gradientGenerator: GradientGenerator, fps: Fps) {
        self.generator = gradientGenerator
        self.fps = fps
        self.totalIterations = self.fps.rawValue / Self.framesPerGeneration
    }
    
    private let generator: GradientGenerator
    private let fps: Fps
    private let totalIterations: Int
    
    private var currentIteration: Int = 0
    
    var c1 = CGPoint.zero
    var c2 = CGPoint.zero
    var c3 = CGPoint.zero
    var c4 = CGPoint.zero
    
    private func generateImages(animationData: AnimationData) -> [UIImage] {
                        
        if currentIteration == 0 {
            c1 = CGPoint(x: animationData.start1.x, y: animationData.start1.y)
            c2 = CGPoint(x: animationData.start2.x, y: animationData.start2.y)
            c3 = CGPoint(x: animationData.start3.x, y: animationData.start3.y)
            c4 = CGPoint(x: animationData.start4.x, y: animationData.start4.y)
        }
        
        let h: CGFloat = 27
                
        let d1x = (animationData.end1.x - animationData.start1.x) / h
        let d1y = (animationData.end1.y - animationData.start1.y) / h
        let d2x = (animationData.end2.x - animationData.start2.x) / h
        let d2y = (animationData.end2.y - animationData.start2.y) / h
        let d3x = (animationData.end3.x - animationData.start3.x) / h
        let d3y = (animationData.end3.y - animationData.start3.y) / h
        let d4x = (animationData.end4.x - animationData.start4.x) / h
        let d4y = (animationData.end4.y - animationData.start4.y) / h
                
        var images = [UIImage]()
        
        let fpsFactor: Int
        
        switch fps {
        case .sixty:
            fpsFactor = 1
        case .thirty:
            fpsFactor = 2
        }
        
        for i in 0..<Self.framesPerGeneration {
            
            let index = (i + Self.framesPerGeneration * currentIteration) * fpsFactor
            
            let cc1 = CGPoint(x: c1.x + d1x * animationCurve[index]!, y: c1.y + d1y * animationCurve[index]!)
            let cc2 = CGPoint(x: c2.x + d2x * animationCurve[index]!, y: c2.y + d2y * animationCurve[index]!)
            let cc3 = CGPoint(x: c3.x + d3x * animationCurve[index]!, y: c3.y + d3y * animationCurve[index]!)
            let cc4 = CGPoint(x: c4.x + d4x * animationCurve[index]!, y: c4.y + d4y * animationCurve[index]!)


            if let image = generator.generateImage(
                c1: cc1,
                c2: cc2,
                c3: cc3,
                c4: cc4
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
        if currentIteration >= totalIterations {
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
    
    let animationCurve: [Int: CGFloat] = [
        0: 0,
        1: 0.25,
        2: 0.50,
        3: 0.75,
        4: 1,
        5: 1.5,
        6: 2,
        7: 2.5,
        8: 3,
        9: 3.5,
        10: 4,
        11: 5,
        12: 6,
        13: 7,
        14: 8,
        15: 9,
        16: 10,
        17: 11,
        18: 12,
        19: 13,
        20: 14,
        21: 15,
        22: 16,
        23: 17,
        24: 18,
        25: 18.3,
        26: 18.6,
        27: 18.9,
        28: 19.2,
        29: 19.5,
        30: 19.8,
        31: 20.1,
        32: 20.4,
        33: 20.7,
        34: 21.0,
        35: 21.3,
        36: 21.6,
        37: 21.9,
        38: 22.2,
        39: 22.5,
        40: 22.8,
        41: 23.1,
        42: 23.4,
        43: 23.7,
        44: 24.0,
        45: 24.3,
        46: 24.6,
        47: 24.9,
        48: 25.2,
        49: 25.5,
        50: 25.8,
        51: 26.1,
        52: 26.3,
        53: 26.4,
        54: 26.5,
        55: 26.6,
        56: 26.7,
        57: 26.8,
        58: 26.9,
        59: 27,
    ]
}
