import Foundation
import UIKit
import CoreGraphics

struct PointXs {
    let c1X: CGFloat
    let c2X: CGFloat
    let c3X: CGFloat
    let c4X: CGFloat
}

struct FactorData {
    let r: CGFloat
    let g: CGFloat
    let b: CGFloat
    let factor: CGFloat
}

struct PixelData {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

struct Poent: Hashable {
    let x: CGFloat
    let y: CGFloat
}

class GradientView: UIView {
        
    //Кэш для рассчета коэффициентов для цветов точек (с первой по четвертую)
    var factor1s = [Poent: FactorData]()
    var factor2s = [Poent: FactorData]()
    var factor3s = [Poent: FactorData]()
    var factor4s = [Poent: FactorData]()
    
    // Цвета, которые были указаны в демо материалах от тг
    let paleYellow = PixelData(a: 255, r: 253, g: 245, b: 203)
    let darkGreen = PixelData(a: 255, r: 65, g: 109, b: 86)
    let yellow = PixelData(a: 255, r: 247, g: 228, b: 140)
    let green = PixelData(a: 255, r: 136, g: 163, b: 133)
    
    // Цвета, которые используются сейчас
    let c = PixelData(a: 255, r: 0, g: 255, b: 255)
    let m = PixelData(a: 255, r: 255, g: 0, b: 255)
    let y = PixelData(a: 255, r: 255, g: 255, b: 0)
    let k = PixelData(a: 255, r: 0, g: 0, b: 0)
    
    //Точки центров
    lazy var c1: CGPoint = {
        CGPoint(x: size, y: 0)
    }()
    lazy var c2: CGPoint = {
        CGPoint(x: 0, y: 0)
    }()
    lazy var c3: CGPoint = {
        CGPoint(x: 0, y: size)
    }()
    lazy var c4: CGPoint = {
        CGPoint(x: size, y: size)
    }()
    
    let size = UIScreen.main.bounds.width / 10
    
    var imageView: UIImageView!
    
    func setImage(image: CGImage?) {
        guard let cgImage = image else {
            return
        }
        
        imageView.image = UIImage(cgImage: cgImage)
    }
    
    func generateImages(ticks: CGFloat) -> [UIImage] {
        
        let d1x = (c2.x - c1.x) / ticks
        let d1y = (c2.y - c1.y) / ticks
        let d2x = (c3.x - c2.x) / ticks
        let d2y = (c3.y - c2.y) / ticks
        let d3x = (c4.x - c3.x) / ticks
        let d3y = (c4.y - c3.y) / ticks
        let d4x = (c1.x - c4.x) / ticks
        let d4y = (c1.y - c4.y) / ticks
        
        var images = [UIImage]()
        
        for _ in 0..<Int(ticks) {
            
            c1 = CGPoint(x: c1.x + d1x, y: c1.y + d1y)
            c2 = CGPoint(x: c2.x + d2x, y: c2.y + d2y)
            c3 = CGPoint(x: c3.x + d3x, y: c3.y + d3y)
            c4 = CGPoint(x: c4.x + d4x, y: c4.y + d4y)
            
            
            if let image = generateImage() {
                images.append(UIImage(cgImage: image))
            }
        }
        return images
    }
    
    func generateImage() -> CGImage? {
        let width = Int(size)
        let height = Int(size)
        
        var xDiffs = [Int: PointXs]()
        
        var colors = [PixelData]()
        
        for y in 0..<height {
            
            let cgY = CGFloat(y)
            let diffsY = (abs(c1.y - cgY), abs(c2.y - cgY), abs(c3.y - cgY), abs(c4.y - cgY))
            
            for x in 0..<width {
                
                let diffsX = xDiff(x: x, xDiffs: &xDiffs)
            
                let factor1 = factorr(xDiff: diffsX.c1X, yDiff: diffsY.0, pixel: m, factors: &factor1s)
                let factor2 = factorr(xDiff: diffsX.c2X, yDiff: diffsY.1, pixel: c, factors: &factor2s)
                let factor3 = factorr(xDiff: diffsX.c3X, yDiff: diffsY.2, pixel: k, factors: &factor3s)
                let factor4 = factorr(xDiff: diffsX.c4X, yDiff: diffsY.3, pixel: self.y, factors: &factor4s)
                
                let sumFactor = factor1.factor + factor2.factor + factor3.factor + factor4.factor
                
                let sumR = factor1.r + factor2.r + factor3.r + factor4.r
                let sumG = factor1.g + factor2.g + factor3.g + factor4.g
                let sumB = factor1.b + factor2.b + factor3.b + factor4.b
                
                colors.append(
                    PixelData(
                        a: 255,
                        r: UInt8(sumR / sumFactor),
                        g: UInt8(sumG / sumFactor),
                        b: UInt8(sumB / sumFactor)
                    )
                )
            }
        }
        
        return imageFromARGB32Bitmap(pixels: colors, width: width, height: height)
    }
    
    private func factorr(
        xDiff: CGFloat,
        yDiff: CGFloat,
        pixel: PixelData,
        factors: inout [Poent: FactorData]) -> FactorData {
        
        let poent = Poent(x: xDiff, y: yDiff)
        let altPoent = Poent(x: yDiff, y: xDiff)
        
        if let saved = factors[poent] {
            return saved
        } else if let saved = factors[altPoent] {
            return saved
        }
        
        let distance = Geometry.distance(x: xDiff, y: yDiff)
        
        let maximum = max(1 - (distance / size), 0)
        let factor = maximum * maximum
        
        let rgb = FactorData(
            r: CGFloat(pixel.r) * factor,
            g: CGFloat(pixel.g) * factor,
            b: CGFloat(pixel.b) * factor,
            factor: factor
        )
        
        factors[poent] = rgb
        factors[altPoent] = rgb
        
        return rgb
    }
    
    private func xDiff(x: Int, xDiffs: inout [Int: PointXs]) -> PointXs {
        if let saved = xDiffs[x] {
            return saved
        }
        let cgX = CGFloat(x)
        
        let diff = PointXs(
            c1X: abs(c1.x - cgX),
            c2X: abs(c2.x - cgX),
            c3X: abs(c3.x - cgX),
            c4X: abs(c4.x - cgX)
        )
        
        xDiffs[x] = diff
        return diff
    }
    
    private func imageFromARGB32Bitmap(pixels: [PixelData], width: Int, height: Int) -> CGImage? {
        guard width > 0 && height > 0 else { return nil }
        guard pixels.count == width * height else { return nil }

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let bitsPerComponent = 8
        let bitsPerPixel = 32

        var data = pixels
        guard let providerRef = CGDataProvider(
            data: NSData(
                bytes: &data,
                length: data.count * MemoryLayout<PixelData>.size
            )
        ) else { return nil }

        return CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: width * MemoryLayout<PixelData>.size,
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
    }
}
