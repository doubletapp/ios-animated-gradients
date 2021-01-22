import Foundation
import UIKit
import CoreGraphics

struct PixelData {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

class GradientView: UIView {
    
    let paleYellow = PixelData(a: 255, r: 253, g: 245, b: 203)
    let darkGreen = PixelData(a: 255, r: 65, g: 109, b: 86)
    let yellow = PixelData(a: 255, r: 247, g: 228, b: 140)
    let green = PixelData(a: 255, r: 136, g: 163, b: 133)
    
    let c = PixelData(a: 255, r: 0, g: 255, b: 255)
    let m = PixelData(a: 255, r: 255, g: 0, b: 255)
    let yi = PixelData(a: 255, r: 255, g: 255, b: 0)
    let k = PixelData(a: 255, r: 0, g: 0, b: 0)
    
    let с4 = CGPoint(x: 0, y: 0)
    let с3 = CGPoint(x: 0, y: UIScreen.main.bounds.height)
    let с2 = CGPoint(x: UIScreen.main.bounds.width, y: UIScreen.main.bounds.height)
    let с1 = CGPoint(x: UIScreen.main.bounds.width, y: 0)
    
    override func draw(_ rect: CGRect) {
        let width = Int(UIScreen.main.bounds.width)
        let height = Int(UIScreen.main.bounds.height)
        
        print("width: \(width), height: \(height)")
        
        var colors = [PixelData]()
        
        for y in 0..<height {
            
            let bottomCoeff = CGFloat(y) / UIScreen.main.bounds.height
            let topCoeff = 1 - bottomCoeff
            
            for x in 0..<width {
                            
                let rightCoeff = CGFloat(x) / UIScreen.main.bounds.width
                let leftCoeff = 1 - rightCoeff
                
                let topR = CGFloat(c.r) * leftCoeff + CGFloat(m.r) * rightCoeff
                let topG = CGFloat(c.g) * leftCoeff + CGFloat(m.g) * rightCoeff
                let topB = CGFloat(c.b) * leftCoeff + CGFloat(m.b) * rightCoeff
                
                let bottomR = CGFloat(k.r) * leftCoeff + CGFloat(yi.r) * rightCoeff
                let bottomG = CGFloat(k.g) * leftCoeff + CGFloat(yi.g) * rightCoeff
                let bottomB = CGFloat(k.b) * leftCoeff + CGFloat(yi.b) * rightCoeff
                
                let pixel = PixelData(
                    a: 255,
                    r: UInt8(topR * topCoeff + bottomR * bottomCoeff),
                    g: UInt8(topG * topCoeff + bottomG * bottomCoeff),
                    b: UInt8(topB * topCoeff + bottomB * bottomCoeff)
                )
                
                colors.append(pixel)
                
                if x == 400, y == 300 {
                    print(pixel)
                }
            }
        }
        
        guard let image = imageFromARGB32Bitmap(pixels: colors, width: width, height: height) else {
            print("failed")
            return
        }
        
        image.draw(at: .zero)
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
