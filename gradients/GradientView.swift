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
    var factor1s = [Poent: (CGFloat, CGFloat, CGFloat, CGFloat)]()
    var factor2s = [Poent: (CGFloat, CGFloat, CGFloat, CGFloat)]()
    var factor3s = [Poent: (CGFloat, CGFloat, CGFloat, CGFloat)]()
    var factor4s = [Poent: (CGFloat, CGFloat, CGFloat, CGFloat)]()
    
    var sumRs = [Poent: CGFloat]()
    var sumGs = [Poent: CGFloat]()
    var sumBs = [Poent: CGFloat]()
    
    var xDiffs = [Int: (CGFloat, CGFloat, CGFloat, CGFloat)]()
    var yDiffs = [Int: (CGFloat, CGFloat, CGFloat, CGFloat)]()
    
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
            
            let diffsY = yDiffs(y: y)
            
            for x in 0..<width {
                
                let diffsX = xDiff(x: x)
                
                let factor1 = factorr1(xDiff: diffsX.0, yDiff: diffsY.0)
                let factor2 = factorr2(xDiff: diffsX.1, yDiff: diffsY.1)
                let factor3 = factorr3(xDiff: diffsX.2, yDiff: diffsY.2)
                let factor4 = factorr4(xDiff: diffsX.3, yDiff: diffsY.3)
                
                let sumFactor = factor1.3 + factor2.3 + factor3.3 + factor4.3
                
                let sumR = factor1.0 + factor2.0 + factor3.0 + factor4.0
                let sumG = factor1.1 + factor2.1 + factor3.1 + factor4.1
                let sumB = factor1.2 + factor2.2 + factor3.2 + factor4.2
                
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
    
    func factorr1(xDiff: CGFloat, yDiff: CGFloat) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        
        let poent = Poent(x: xDiff, y: yDiff)
        let altPoent = Poent(x: yDiff, y: xDiff)
        
        if let saved = factor1s[poent] {
            return saved
        } else if let saved = factor1s[altPoent] {
            return saved
        }
        
        let distance = dist(x: xDiff, y: yDiff)
        
        let maximum = max(1 - (distance / UIScreen.main.bounds.width), 0)
        let factor = maximum * maximum
        
        let rgb = (
            CGFloat(darkGreen.r) * factor,
            CGFloat(darkGreen.g) * factor,
            CGFloat(darkGreen.b) * factor,
            factor
        )
        
        factor1s[poent] = rgb
        factor1s[altPoent] = rgb
        
        return rgb
    }
    
    func factorr2(xDiff: CGFloat, yDiff: CGFloat) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        
        let poent = Poent(x: xDiff, y: yDiff)
        let altPoent = Poent(x: yDiff, y: xDiff)
        
        if let saved = factor2s[poent] {
            return saved
        } else if let saved = factor2s[altPoent] {
            return saved
        }
        
        let distance = dist(x: xDiff, y: yDiff)
        
        let maximum = max(1 - (distance / UIScreen.main.bounds.width), 0)
        let factor = maximum * maximum
        
        let rgb = (
            CGFloat(yellow.r) * factor,
            CGFloat(yellow.g) * factor,
            CGFloat(yellow.b) * factor,
            factor
        )
        
        factor2s[poent] = rgb
        factor2s[altPoent] = rgb
        
        return rgb
    }
    
    func factorr3(xDiff: CGFloat, yDiff: CGFloat) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        
        let poent = Poent(x: xDiff, y: yDiff)
        let altPoent = Poent(x: yDiff, y: xDiff)
        
        if let saved = factor3s[poent] {
            return saved
        } else if let saved = factor3s[altPoent] {
            return saved
        }
        
        let distance = dist(x: xDiff, y: yDiff)
        
        let maximum = max(1 - (distance / UIScreen.main.bounds.width), 0)
        let factor = maximum * maximum
        
        let rgb = (
            CGFloat(green.r) * factor,
            CGFloat(green.g) * factor,
            CGFloat(green.b) * factor,
            factor
        )
        
        factor3s[poent] = rgb
        factor3s[altPoent] = rgb
        
        return rgb
    }
    
    func factorr4(xDiff: CGFloat, yDiff: CGFloat) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        
        let poent = Poent(x: xDiff, y: yDiff)
        let altPoent = Poent(x: yDiff, y: xDiff)
        
        if let saved = factor4s[poent] {
            return saved
        } else if let saved = factor4s[altPoent] {
            return saved
        }
        
        let distance = dist(x: xDiff, y: yDiff)
        
        let maximum = max(1 - (distance / UIScreen.main.bounds.width), 0)
        let factor = maximum * maximum
        
        let rgb = (
            CGFloat(paleYellow.r) * factor,
            CGFloat(paleYellow.g) * factor,
            CGFloat(paleYellow.b) * factor,
            factor
        )
        
        factor4s[poent] = rgb
        factor4s[altPoent] = rgb
        
        return rgb
    }
    
    func yDiffs(y: Int) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        if let saved = yDiffs[y] {
            return saved
        }
        let cgY = CGFloat(y)
        let diff = (abs(c1.y - cgY), abs(c2.y - cgY), abs(c3.y - cgY), abs(c4.y - cgY))
        yDiffs[y] = diff
        return diff
    }
    
    func xDiff(x: Int) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        if let saved = xDiffs[x] {
            return saved
        }
        let cgX = CGFloat(x)
        let diff = (abs(c1.x - cgX), abs(c2.x - cgX), abs(c3.x - cgX), abs(c4.x - cgX))
        xDiffs[x] = diff
        return diff
    }
    
    func factorr(xDiff: CGFloat, yDiff: CGFloat) -> CGFloat {
        
        let poent = Poent(x: xDiff, y: yDiff)
        let altPoent = Poent(x: yDiff, y: xDiff)
        
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
    
    func imageFromARGB32Bitmap(pixels: [PixelData], width: Int, height: Int) -> UIImage? {
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
