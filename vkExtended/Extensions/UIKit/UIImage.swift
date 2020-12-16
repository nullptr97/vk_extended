//
//  UIImage.swift
//  VKExt
//
//  Created by programmist_NA on 20.05.2020.
//

import Foundation
import ImageIO
import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}
extension UIImage {
    func bluredImage(radius: CGFloat = 3, bounds: CGRect = .zero) -> UIImage {
        if let source = self.cgImage {
            let context = CIContext(options: nil)
            let inputImage = CIImage(cgImage: source)
            
            let clampFilter = CIFilter(name: "CIAffineClamp")
            clampFilter?.setDefaults()
            clampFilter?.setValue(inputImage, forKey: kCIInputImageKey)
            
            if let clampedImage = clampFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                let explosureFilter = CIFilter(name: "CIExposureAdjust")
                explosureFilter?.setValue(clampedImage, forKey: kCIInputImageKey)
                explosureFilter?.setValue(0.0, forKey: kCIInputEVKey)
                
                if let explosureImage = explosureFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                    let filter = CIFilter(name: "CIGaussianBlur")
                    filter?.setValue(explosureImage, forKey: kCIInputImageKey)
                    filter?.setValue("\(radius)", forKey: kCIInputRadiusKey)
                    
                    if let result = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
                        let cgImage = context.createCGImage(result, from: bounds)
                        let returnImage = UIImage(cgImage: cgImage!)
                        return returnImage
                    }
                }
            }
        }
        return UIImage()
    }
    
    func blurImage(with radius: CGFloat) -> UIImage {
        let imageToBlur = CIImage(image: self)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter?.setValue(imageToBlur, forKey: "inputImage")
        blurfilter?.setValue(radius, forKey: "inputRadius")
        let resultImage = blurfilter?.value(forKey: "outputImage") as! CIImage
        return UIImage(ciImage: resultImage)
    }
}

extension UIImage {
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL = URL(string: gifUrl) else {
            print("image named \"\(gifUrl)\" doesn't exist")
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else {
            print("SwiftGif: This image named \"\(name)\" does not exist")
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.025
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.025 {
            delay = 0.025
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 250.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 250.0)
        
        return animation
    }
    
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

public typealias GifLevelOfIntegrity = Float

extension GifLevelOfIntegrity {
    public static let highestNoFrameSkipping: GifLevelOfIntegrity = 1
    public static let `default`: GifLevelOfIntegrity = 0.8
    public static let lowForManyGifs: GifLevelOfIntegrity = 0.5
    public static let lowForTooManyGifs: GifLevelOfIntegrity = 0.2
    public static let superLowForSlideShow: GifLevelOfIntegrity = 0.1
}

enum GifParseError: Error {
    case invalidFilename
    case noImages
    case noProperties
    case noGifDictionary
    case noTimingInfo
}

extension GifParseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidFilename:
            return "Invalid file name"
        case .noImages,.noProperties, .noGifDictionary,.noTimingInfo:
            return "Invalid gif file "
        }
    }
}

public extension UIImage {
    /// Convenience initializer. Creates a gif with its backing data.
    ///
    /// - Parameter imageData: The actual image data, can be GIF or some other format
    /// - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
    convenience init?(imageData:Data, levelOfIntegrity: GifLevelOfIntegrity = .default) throws {
        do {
            try self.init(gifData: imageData, levelOfIntegrity: levelOfIntegrity)
        } catch {
            self.init(data: imageData)
        }
    }

    /// Convenience initializer. Creates a image with its backing data.
    ///
    /// - Parameter imageName: Filename
    /// - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
    convenience init?(imageName: String, levelOfIntegrity: GifLevelOfIntegrity = .default) throws {
        self.init()

        do {
            try setGif(imageName, levelOfIntegrity: levelOfIntegrity)
        } catch {
            self.init(named: imageName)
        }
    }
}

// MARK: - Inits
public extension UIImage {
    
    /// Convenience initializer. Creates a gif with its backing data.
    ///
    /// - Parameter gifData: The actual gif data
    /// - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
    convenience init(gifData:Data, levelOfIntegrity: GifLevelOfIntegrity = .default) throws {
        self.init()
        try setGifFromData(gifData, levelOfIntegrity: levelOfIntegrity)
    }
    
    /// Convenience initializer. Creates a gif with its backing data.
    ///
    /// - Parameter gifName: Filename
    /// - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
    convenience init(gifName: String, levelOfIntegrity: GifLevelOfIntegrity = .default) throws {
        self.init()
        try setGif(gifName, levelOfIntegrity: levelOfIntegrity)
    }
    
    /// Set backing data for this gif. Overwrites any existing data.
    ///
    /// - Parameter data: The actual gif data
    /// - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
    func setGifFromData(_ data: Data, levelOfIntegrity: GifLevelOfIntegrity) throws {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return }
        self.imageSource = imageSource
        imageData = data
        
        calculateFrameDelay(try delayTimes(imageSource), levelOfIntegrity: levelOfIntegrity)
        calculateFrameSize()
    }
    
    /// Set backing data for this gif. Overwrites any existing data.
    ///
    /// - Parameter name: Filename
    func setGif(_ name: String) throws {
        try setGif(name, levelOfIntegrity: .default)
    }
    
    /// Check the number of frame for this gif
    ///
    /// - Return number of frames
    func framesCount() -> Int {
        return displayOrder?.count ?? 0
    }
    
    /// Set backing data for this gif. Overwrites any existing data.
    ///
    /// - Parameter name: Filename
    /// - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
    func setGif(_ name: String, levelOfIntegrity: GifLevelOfIntegrity) throws {
        if let url = Bundle.main.url(forResource: name,
                                     withExtension: name.pathExtension() == "gif" ? "" : "gif") {
            if let data = try? Data(contentsOf: url) {
                try setGifFromData(data, levelOfIntegrity: levelOfIntegrity)
            }
        } else {
            throw GifParseError.invalidFilename
        }
    }
    
    func clear() {
        imageData = nil
        imageSource = nil
        displayOrder = nil
        imageCount = nil
        imageSize = nil
        displayRefreshFactor = nil
    }
    
    // MARK: Logic
    
    private func convertToDelay(_ pointer:UnsafeRawPointer?) -> Float? {
        if pointer == nil {
            return nil
        }
        
        return unsafeBitCast(pointer, to:AnyObject.self).floatValue
    }
    
    /// Get delay times for each frames
    ///
    /// - Parameter imageSource: reference to the gif image source
    /// - Returns array of delays
    private func delayTimes(_ imageSource:CGImageSource) throws -> [Float] {
        let imageCount = CGImageSourceGetCount(imageSource)
        
        guard imageCount > 0 else {
            throw GifParseError.noImages
        }
        
        var imageProperties = [CFDictionary]()
        
        for i in 0..<imageCount {
            if let dict = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) {
                imageProperties.append(dict)
            } else {
                throw GifParseError.noProperties
            }
        }
        
        let frameProperties = try imageProperties.map() { (dict: CFDictionary) -> CFDictionary in
            let key = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
            let value = CFDictionaryGetValue(dict, key)
            
            if value == nil {
                throw GifParseError.noGifDictionary
            }
            
            return unsafeBitCast(value, to: CFDictionary.self)
        }
        
        let EPS:Float = 1e-6
        
        let frameDelays:[Float] = try frameProperties.map() {
            let unclampedKey = Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()
            let unclampedPointer:UnsafeRawPointer? = CFDictionaryGetValue($0, unclampedKey)
            
            if let value = convertToDelay(unclampedPointer), value >= EPS {
                return value
            }
            
            let clampedKey = Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()
            let clampedPointer:UnsafeRawPointer? = CFDictionaryGetValue($0, clampedKey)
            
            if let value = convertToDelay(clampedPointer) {
                return value
            }
            
            throw GifParseError.noTimingInfo
        }
        
        return frameDelays
    }
    
    /// Compute backing data for this gif
    ///
    /// - Parameter delaysArray: decoded delay times for this gif
    /// - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
    private func calculateFrameDelay(_ delaysArray: [Float], levelOfIntegrity: GifLevelOfIntegrity) {
        let levelOfIntegrity = max(0, min(1, levelOfIntegrity))
        var delays = delaysArray
        
        // Factors send to CADisplayLink.frameInterval
        let displayRefreshFactors = [60, 30, 20, 15, 12, 10, 6, 5, 4, 3, 2, 1]
        
        // maxFramePerSecond,default is 60
        let maxFramePerSecond = displayRefreshFactors[0]
        
        // frame numbers per second
        let displayRefreshRates = displayRefreshFactors.map { maxFramePerSecond / $0 }
        
        // time interval per frame
        let displayRefreshDelayTime = displayRefreshRates.map { 1 / Float($0) }
        
        // caclulate the time when each frame should be displayed at(start at 0)
        for i in delays.indices.dropFirst() {
            delays[i] += delays[i - 1]
        }
        
        //find the appropriate Factors then BREAK
        for (i, delayTime) in displayRefreshDelayTime.enumerated() {
            let displayPosition = delays.map { Int($0 / delayTime) }
            var frameLoseCount: Float = 0
            
            for j in displayPosition.indices.dropFirst() where displayPosition[j] == displayPosition[j - 1] {
                frameLoseCount += 1
            }
            
            if displayPosition.first == 0 {
                frameLoseCount += 1
            }
            
            if frameLoseCount <= Float(displayPosition.count) * (1 - levelOfIntegrity) || i == displayRefreshDelayTime.count - 1 {
                imageCount = displayPosition.last
                displayRefreshFactor = displayRefreshFactors[i]
                displayOrder = []
                var oldIndex = 0
                var newIndex = 1
                let imageCount = self.imageCount ?? 0
                
                while newIndex <= imageCount && oldIndex < displayPosition.count {
                    if newIndex <= displayPosition[oldIndex] {
                        displayOrder?.append(oldIndex)
                        newIndex += 1
                    } else {
                        oldIndex += 1
                    }
                }
                
                break
            }
        }
    }
    
    /// Compute frame size for this gif
    private func calculateFrameSize(){
        guard let imageSource = imageSource,
            let imageCount = imageCount,
            let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
                return
        }
        
        let image = UIImage(cgImage: cgImage)
        imageSize = Int(image.size.height * image.size.width * 4) * imageCount / 1_000_000
    }
}

// MARK: - Properties
private let _imageSourceKey = malloc(4)
private let _displayRefreshFactorKey = malloc(4)
private let _imageSizeKey = malloc(4)
private let _imageCountKey = malloc(4)
private let _displayOrderKey = malloc(4)
private let _imageDataKey = malloc(4)

public extension UIImage {
    
    var imageSource: CGImageSource? {
        get {
            let result = objc_getAssociatedObject(self, _imageSourceKey!)
            return result == nil ? nil : (result as! CGImageSource)
        }
        set {
            objc_setAssociatedObject(self, _imageSourceKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var displayRefreshFactor: Int?{
        get { return objc_getAssociatedObject(self, _displayRefreshFactorKey!) as? Int }
        set { objc_setAssociatedObject(self, _displayRefreshFactorKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var imageSize: Int?{
        get { return objc_getAssociatedObject(self, _imageSizeKey!) as? Int }
        set { objc_setAssociatedObject(self, _imageSizeKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var imageCount: Int?{
        get { return objc_getAssociatedObject(self, _imageCountKey!) as? Int }
        set { objc_setAssociatedObject(self, _imageCountKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var displayOrder: [Int]?{
        get { return objc_getAssociatedObject(self, _displayOrderKey!) as? [Int] }
        set { objc_setAssociatedObject(self, _displayOrderKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var imageData:Data? {
        get {
            let result = objc_getAssociatedObject(self, _imageDataKey!)
            return result == nil ? nil : (result as? Data)
        }
        set {
            objc_setAssociatedObject(self, _imageDataKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension String {
    fileprivate func pathExtension() -> String {
        return (self as NSString).pathExtension
    }
}
