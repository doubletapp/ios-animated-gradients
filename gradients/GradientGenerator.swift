import Foundation
import UIKit

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

struct PointData {
    let point: CGPoint
    let pixel: PixelData
}

struct PointXs {
    let c1X: CGFloat
    let c2X: CGFloat
    let c3X: CGFloat
    let c4X: CGFloat
}

class GradientGenerator {
    
    init(size: CGFloat, pixels: PixelsData) {
        self.size = size
        self.pixels = pixels
    }
    
    let size: CGFloat
    let pixels: PixelsData
    
    var factor1s = [Poent: FactorData]()
    var factor2s = [Poent: FactorData]()
    var factor3s = [Poent: FactorData]()
    var factor4s = [Poent: FactorData]()
    
    func generateImage(c1: CGPoint, c2: CGPoint, c3: CGPoint, c4: CGPoint) -> UIImage? {
        let width = Int(size)
        let height = Int(size)
        
        var xDiffs = [Int: PointXs]()
        
        var colors = [PixelData]()
        
        for y in 0..<height {
            
            let cgY = CGFloat(y)
            let diffsY = (abs(c1.y - cgY), abs(c2.y - cgY), abs(c3.y - cgY), abs(c4.y - cgY))
            
            for x in 0..<width {
                
                let diffsX = xDiff(x: x, xDiffs: &xDiffs, c1: c1, c2: c2, c3: c3, c4: c4)
            
                let factor1 = factorr(xDiff: diffsX.c1X, yDiff: diffsY.0, pixel: pixels.pixel1, factors: &factor1s)
                let factor2 = factorr(xDiff: diffsX.c2X, yDiff: diffsY.1, pixel: pixels.pixel2, factors: &factor2s)
                let factor3 = factorr(xDiff: diffsX.c3X, yDiff: diffsY.2, pixel: pixels.pixel3, factors: &factor3s)
                let factor4 = factorr(xDiff: diffsX.c4X, yDiff: diffsY.3, pixel: pixels.pixel4, factors: &factor4s)
                
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
        
        guard let cgImage = imageFromARGB32Bitmap(pixels: colors, width: width, height: height) else { return nil }
        
        return UIImage(cgImage: cgImage)
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
        
        let distance = calculateDistance(x: xDiff, y: yDiff)
        
        let maximum = max(1 - (distance / size), 0)
        let factor = maximum * maximum * maximum * maximum
        
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
    
    private func xDiff(x: Int, xDiffs: inout [Int: PointXs], c1: CGPoint, c2: CGPoint, c3: CGPoint, c4: CGPoint) -> PointXs {
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
    
    var distances = [Poent : CGFloat]()

    func calculateDistance(x: CGFloat, y: CGFloat) -> CGFloat {
        
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
