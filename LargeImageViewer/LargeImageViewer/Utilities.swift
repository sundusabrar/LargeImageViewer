//
//  IVUtilities.swift
//  ImageViewer
//
//  Created by Sundus Abrar on 28/07/2019.
//  Copyright © 2019 Cinemo. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

//Storyboard View Controller Identifiers

struct SBIdentifiers {
    static let kImageListView = "ImageListView"
    static let kImageSelectView = "ImageSelectView"
}

enum CameraPermission {
    case Granted
}

enum MediaType {
    case Camera
    case PhotoLibrary
}


class IVUtilities : NSObject {
    
    static let shared = IVUtilities()
    
    static func mainStoryboard() -> UIStoryboard {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard
    }
    
    // Downsampling large images for display at smaller size
    func downsample(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        
        let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions =  [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                  kCGImageSourceShouldCacheImmediately: true,
                                  kCGImageSourceCreateThumbnailWithTransform: true,
                                  kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
       
        let downsampledImage =   CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
       
        return UIImage(cgImage: downsampledImage)
    }
    
    func saveThumbnail(forImage image: UIImage, withName thumbName: String) -> URL {
        let imagePath: String = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(thumbName).png"
        let imageUrl: URL = URL(fileURLWithPath: imagePath)
        
        try? UIImagePNGRepresentation(image)?.write(to: imageUrl)
        
        return imageUrl
    }
    
    func fetchThumbnail(forImage imageName: String) -> UIImage {
        let imagePath: String = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(imageName).png"
        let imageUrl: URL = URL(fileURLWithPath: imagePath)
        
        if FileManager.default.fileExists(atPath: imagePath),
            let imageData: Data = try? Data(contentsOf: imageUrl),
            let image: UIImage = UIImage(data: imageData, scale: UIScreen.main.scale) {
            return image
        }
        
        return UIImage()
    }
    
    func fetchSavedImages() -> [URL] {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            return fileURLs.reversed()
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        return [URL]()
    }
    
    func imageOrientation(_ srcImage: UIImage)->UIImage {
        if srcImage.imageOrientation == UIImageOrientation.up {
            return srcImage
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch srcImage.imageOrientation {
        case UIImageOrientation.down, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: srcImage.size.width, y: srcImage.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))// replace M_PI by Double.pi when using swift 4.0
            break
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: srcImage.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))//  4.0
            break
        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: srcImage.size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))// replace M_PI_2 by Double.pi/2 when using swift 4.0
            break
        case UIImageOrientation.up, UIImageOrientation.upMirrored:
            break
        }
        switch srcImage.imageOrientation {
        case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
            transform.translatedBy(x: srcImage.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
            transform.translatedBy(x: srcImage.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
            break
        }
        let ctx:CGContext = CGContext(data: nil, width: Int(srcImage.size.width), height: Int(srcImage.size.height), bitsPerComponent: (srcImage.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (srcImage.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.concatenate(transform)
        switch srcImage.imageOrientation {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
            ctx.draw(srcImage.cgImage!, in: CGRect(x: 0, y: 0, width: srcImage.size.height, height: srcImage.size.width))
            break
        default:
            ctx.draw(srcImage.cgImage!, in: CGRect(x: 0, y: 0, width: srcImage.size.width, height: srcImage.size.height))
            break
        }
        let cgimg:CGImage = ctx.makeImage()!
        let img:UIImage = UIImage(cgImage: cgimg)
        return img
    }
}
