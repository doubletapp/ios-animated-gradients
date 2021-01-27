import Foundation
import UIKit
import CoreGraphics

struct PixelData {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

struct FactorData {
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    var f: CGFloat
}

struct PointMeta {
    let dist: CGFloat
    let pixel: PixelData
}

struct Poent: Hashable {
    let x: CGFloat
    let y: CGFloat
}

class GradientView: UIView {
    
    var distances = [Poent : CGFloat]()
    var factors = [Poent: CGFloat]()
    
    let paleYellow = PixelData(a: 255, r: 253, g: 245, b: 203)
    let darkGreen = PixelData(a: 255, r: 65, g: 109, b: 86)
    let yellow = PixelData(a: 255, r: 247, g: 228, b: 140)
    let green = PixelData(a: 255, r: 136, g: 163, b: 133)
    
    let c = PixelData(a: 255, r: 0, g: 255, b: 255)
    let m = PixelData(a: 255, r: 255, g: 0, b: 255)
    let y = PixelData(a: 255, r: 255, g: 255, b: 0)
    let k = PixelData(a: 255, r: 0, g: 0, b: 0)
    
    var c1 = CGPoint(x: UIScreen.main.bounds.width - 75, y: 75)
    var c2 = CGPoint(x: 150, y: 250)
    
    var c3 : CGPoint {
        return CGPoint(x: UIScreen.main.bounds.width - c1.x, y: UIScreen.main.bounds.height - c1.y)
    }
    
    var c4 : CGPoint {
        return CGPoint(x: UIScreen.main.bounds.width - c2.x, y: UIScreen.main.bounds.height - c2.y)
    }
    
    override func draw(_ rect: CGRect) {
        let width = Int(UIScreen.main.bounds.width)
        let height = Int(UIScreen.main.bounds.height)
        
        var colors = [PixelData]()
        
        for y in 0..<height {
            
            let yDiff1 = CGFloat(y) - c1.y
            let yDiff2 = CGFloat(y) - c2.y
            let yDiff3 = CGFloat(y) - c3.y
            let yDiff4 = CGFloat(y) - c4.y
            
            for x in 0..<width {

                let xDiff1 = c1.x - CGFloat(x)
                let factor1 = factorr(xDiff: xDiff1, yDiff: yDiff1)
                
                let xDiff2 = c2.x - CGFloat(x)
                let factor2 = factorr(xDiff: xDiff2, yDiff: yDiff2)
                
                let xDiff3 = c3.x - CGFloat(x)
                let factor3 = factorr(xDiff: xDiff3, yDiff: yDiff3)
                
                let xDiff4 = c4.x - CGFloat(x)
                let factor4 = factorr(xDiff: xDiff4, yDiff: yDiff4)
                
                let sumFactor = factor1 + factor2 + factor3 + factor4
                
                let sumR = CGFloat(darkGreen.r) * factor1
                    + CGFloat(yellow.r) * factor2
                    + CGFloat(green.r) * factor3
                    + CGFloat(paleYellow.r) * factor4
                
                let sumG = CGFloat(darkGreen.g) * factor1
                    + CGFloat(yellow.g) * factor2
                    + CGFloat(green.g) * factor3
                    + CGFloat(paleYellow.g) * factor4
                
                let sumB = CGFloat(darkGreen.b) * factor1
                    + CGFloat(yellow.b) * factor2
                    + CGFloat(green.b) * factor3
                    + CGFloat(paleYellow.b) * factor4
                
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
        
        guard let image = imageFromARGB32Bitmap(pixels: colors, width: width, height: height) else {
            print("failed")
            return
        }
        
        image.draw(at: .zero)
    }
    
    func factorr(xDiff: CGFloat, yDiff: CGFloat) -> CGFloat {
        
        let poent = Poent(x: abs(xDiff), y: abs(yDiff))
        let altPoent = Poent(x: abs(yDiff), y: abs(xDiff))
        
        if let saved = factors[poent] {
            return saved
        } else if let saved = factors[altPoent] {
            return saved
        }
        
        let distance = dist(x: xDiff, y: yDiff)
        
        let maximum = max(1 - (distance / UIScreen.main.bounds.width), 0)
        let factor = maximum * maximum
        
        factors[poent] = factor
        factors[altPoent] = factor
        
        return factor
    }
    
    func dist(x: CGFloat, y: CGFloat) -> CGFloat {
        
        let poent = Poent(x: abs(x), y: abs(y))
        let altPoent = Poent(x: abs(y), y: abs(x))
        
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
    
    func imageFromARGB32Bitmap(pixels: [PixelData], width: Int, height: Int) -> UIImage? {
        guard width > 0 && height > 0 else { return nil }
        guard pixels.count == width * height else { return nil }

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let bitsPerComponent = 8
        let bitsPerPixel = 32

        var data = pixels
        guard let providerRef = CGDataProvider(data: NSData(bytes: &data,
                                length: data.count * MemoryLayout<PixelData>.size)
            )
            else { return nil }

        guard let cgim = CGImage(
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
            else { return nil }

        return UIImage(cgImage: cgim)
    }
    
}
