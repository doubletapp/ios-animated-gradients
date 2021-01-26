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
    let slope: CGFloat
    let intercept: CGFloat
    let left: Bool
    let pixel: PixelData
}

class GradientView: UIView {
    
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
        
        let points = [
            (c1, darkGreen),
            (c2, yellow),
            (c3, green),
            (c4, paleYellow)
        ]
                
        var colors = [PixelData]()
        
        for y in 0..<height {
            for x in 0..<width {

                let pointsMeta = points.map({ (p, pixel) -> PointMeta in
                    
                    let slope = -(p.y - CGFloat(y)) / (p.x - CGFloat(x))
                    let intercept = p.x * slope - p.y
                    
                    return PointMeta(
                        dist: dist(x1: p.x, x2: CGFloat(x), y1: p.y, y2: CGFloat(y)),
                        slope: slope,
                        intercept: intercept,
                        left: CGFloat(y) <= (slope * CGFloat(x) + intercept),
                        pixel: pixel
                    )
                }).sorted { a, b in
                    a.dist > b.dist
                }
                                
                let result = pointsMeta.reduce(
                    FactorData(r: 0, g: 0, b: 0, f: 0)
                ) { (t, c) in
                    let maximum = max(1 - (c.dist / CGFloat(width)), 0)
                    let factor = maximum * maximum
                    return FactorData(
                        r: t.r + CGFloat(c.pixel.r) * factor,
                        g: t.g + CGFloat(c.pixel.g) * factor,
                        b: t.b + CGFloat(c.pixel.b) * factor,
                        f: t.f + factor
                    )
                }
                
                colors.append(
                    PixelData(
                        a: 255,
                        r: UInt8(result.r / result.f),
                        g: UInt8(result.g / result.f),
                        b: UInt8(result.b / result.f)
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
    
    func dist(x1: CGFloat, x2: CGFloat, y1: CGFloat, y2: CGFloat) -> CGFloat {
        let x = CGFloat(x1 - x2)
        let y = CGFloat(y1 - y2)
        return sqrt(x * x + y * y)
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
