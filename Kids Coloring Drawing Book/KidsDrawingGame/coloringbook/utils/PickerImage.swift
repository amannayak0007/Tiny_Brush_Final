import UIKit
import ImageIO

open class PickerImage {
    
    var image:UIImage?
    private var width:Int
    private var height:Int
    
    private var imageContext:CGContext!
    private var imageData: UnsafeMutablePointer<UInt8>!
    
    fileprivate func createImageFromData(_ width:Int, height:Int) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        imageContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)!
        
        image = UIImage(cgImage: imageContext.makeImage()!)
        
        let rawPointer = imageContext.data
        imageData = rawPointer!.bindMemory(to: UInt8.self, capacity: width * height * 4)
    }
    
    func changeSize(_ width:Int, height:Int) {
        self.width = width
        self.height = height
        createImageFromData(width, height: height)
    }
    
    init(width:Int, height:Int) {
        self.width = width
        self.height = height
        createImageFromData(width, height: height)
    }
    
    open func writeColorData(_ h:CGFloat, a:CGFloat) {
        
        if width == 0 || height == 0 {
            return
        }
        
        var i:Int = 0
        let h360:CGFloat = ((h == 1 ? 0 : h) * 360) / 60.0
        let sector:Int = Int(floor(h360))
        let f:CGFloat = h360 - CGFloat(sector)
        let f1:CGFloat = 1.0 - f
        var p:CGFloat = 0.0
        var q:CGFloat = 0.0
        var t:CGFloat = 0.0
        let sd:CGFloat = 1.0 / CGFloat(width)
        let vd:CGFloat =  1 / CGFloat(height)
        
        var double_s:CGFloat = 0
        var pf:CGFloat = 0
        let v_range = 0..<height
        let s_range = 0..<width
        
        for v in v_range {
            pf = 255 * CGFloat(v) * vd
            for s in s_range {
                i = (v * width + s) * 4
                imageData.advanced(by: i).pointee = UInt8(255)
                if s == 0 {
                    q = pf
                    imageData.advanced(by: i+1).pointee = UInt8(q)
                    imageData.advanced(by: i+2).pointee = UInt8(q)
                    imageData.advanced(by: i+3).pointee = UInt8(q)
                    continue
                }
                
                double_s = CGFloat(s) * sd
                p = pf * (1.0 - double_s)
                q = pf * (1.0 - double_s * f)
                t = pf * ( 1.0 - double_s  * f1)
                
                switch(sector) {
                case 0:
                    imageData.advanced(by: i+1).pointee = UInt8(pf)
                    imageData.advanced(by: i+2).pointee = UInt8(t)
                    imageData.advanced(by: i+3).pointee = UInt8(p)
                case 1:
                    imageData.advanced(by: i+1).pointee = UInt8(q)
                    imageData.advanced(by: i+2).pointee = UInt8(pf)
                    imageData.advanced(by: i+3).pointee = UInt8(p)
                case 2:
                    imageData.advanced(by: i+1).pointee = UInt8(p)
                    imageData.advanced(by: i+2).pointee = UInt8(pf)
                    imageData.advanced(by: i+3).pointee = UInt8(t)
                case 3:
                    imageData.advanced(by: i+1).pointee = UInt8(p)
                    imageData.advanced(by: i+2).pointee = UInt8(q)
                    imageData.advanced(by: i+3).pointee = UInt8(pf)
                case 4:
                    imageData.advanced(by: i+1).pointee = UInt8(t)
                    imageData.advanced(by: i+2).pointee = UInt8(p)
                    imageData.advanced(by: i+3).pointee = UInt8(pf)
                default:
                    imageData.advanced(by: i+1).pointee = UInt8(pf)
                    imageData.advanced(by: i+2).pointee = UInt8(p)
                    imageData.advanced(by: i+3).pointee = UInt8(q)
                }
                
                
            }
        }
        
        image = UIImage(cgImage: imageContext.makeImage()!)
    }
    
    
}
