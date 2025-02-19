//
//  Image.swift
//  FitCheck
//
//  Created by Himanshu Matharu on 2024-02-06.
//

import SwiftUI
import UIKit
import Vision

extension UIImage {
    static func imageData(from imageName: String, as format: ImageFormat) -> Data? {
        let image = UIImage(named: imageName)
        switch format {
        case let .jpeg(compressionQuality):
            return image?.jpegData(compressionQuality: compressionQuality)
        case .png:
            return image?.pngData()
        }
    }

    enum ImageFormat {
        case jpeg(compressionQuality: CGFloat)
        case png
    }

    static func detectOuterContour(from uiImage: UIImage) -> (Path, [CGPoint]) {
        let request = VNDetectContoursRequest()
        request.contrastAdjustment = 1.0
        request.detectsDarkOnLight = true
        request.maximumImageDimension = 512

        let handler = VNImageRequestHandler(cgImage: uiImage.cgImage!, options: [:])

        do {
            try handler.perform([request])
            guard let results = request.results as? [VNContoursObservation] else { return (Path(), []) }

            guard let largestContour = results.max(by: { $0.confidence < $1.confidence }) else {
                return (Path(), [])
            }

            var path = Path()
            var debugPoints: [CGPoint] = []

            // Assuming the first contour is the outermost
            let contour = largestContour.topLevelContours.first

            // Iterate over contour segments
            contour?.normalizedPoints.forEach { normalizedPoint in
                let point = CGPoint(x: CGFloat(normalizedPoint.x) * uiImage.size.width,
                                    y: CGFloat(normalizedPoint.y) * uiImage.size.height)
                if debugPoints.isEmpty {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
                debugPoints.append(point)
            }
            path.closeSubpath()

            return (path, debugPoints)
        } catch {
            print("Error detecting contours: \(error)")
            return (Path(), [])
        }
    }

    static func detectContours(in image: UIImage) -> [Path] {
        let request = VNDetectContoursRequest()
        request.contrastAdjustment = 1.0
        request.detectsDarkOnLight = true
        request.maximumImageDimension = 512 // This value is arbitrary; adjust based on your needs

        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        var paths: [Path] = []

        do {
            try handler.perform([request])
            guard let observations = request.results else { return [] }

            for observation in observations {
                // Convert the normalized path of each contour into a SwiftUI path
                paths.append(Path(observation.normalizedPath))
            }
        } catch {
            print("Failed to perform contour detection: \(error.localizedDescription)")
        }

        return paths
    }

    var fixedOrientation: UIImage {
        guard imageOrientation != .up else { return self }

        var transform: CGAffineTransform = .identity
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform
                .translatedBy(x: size.width, y: size.height).rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform
                .translatedBy(x: size.width, y: 0).rotated(by: .pi)
        case .right, .rightMirrored:
            transform = transform
                .translatedBy(x: 0, y: size.height).rotated(by: -.pi / 2)
        case .upMirrored:
            transform = transform
                .translatedBy(x: size.width, y: 0).scaledBy(x: -1, y: 1)
        default:
            break
        }

        guard
            let cgImage = cgImage,
            let colorSpace = cgImage.colorSpace,
            let context = CGContext(
                data: nil, width: Int(size.width), height: Int(size.height),
                bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0,
                space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue
            )
        else { return self }
        context.concatenate(transform)

        var rect: CGRect
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            rect = CGRect(x: 0, y: 0, width: size.height, height: size.width)
        default:
            rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }

        context.draw(cgImage, in: rect)
        return context.makeImage().map { UIImage(cgImage: $0) } ?? self
    }

    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }

    func scaled(by factor: CGFloat) -> UIImage? {
        let newSize = CGSize(width: size.width * factor, height: size.height * factor)
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        draw(in: CGRect(origin: .zero, size: newSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }

    func tinted(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return nil }

        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.interpolationQuality = .high

        let rect = CGRect(origin: .zero, size: size)

        // Apply the tint color
        context.setBlendMode(.normal)
        color.setFill()
        context.fill(rect)

        // Mask the tinted color with the image's alpha values
        context.setBlendMode(.destinationIn)
        context.draw(cgImage, in: rect)

        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
        UIGraphicsEndImageContext()

        return tintedImage
    }

    func resized(to size: CGSize) -> UIImage? {
        let aspectWidth = size.width / self.size.width
        let aspectHeight = size.height / self.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)

        let newSize = CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = .high
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }

    func cropped(toAspectRatio aspectRatio: CGFloat) -> UIImage? {
        let originalAspectRatio = size.width / size.height
        var cropRect: CGRect
        if aspectRatio > originalAspectRatio {
            let newHeight = size.width / aspectRatio
            cropRect = CGRect(x: 0, y: (size.height - newHeight) / 2, width: size.width, height: newHeight)
        } else {
            let newWidth = size.height * aspectRatio
            cropRect = CGRect(x: (size.width - newWidth) / 2, y: 0, width: newWidth, height: size.height)
        }
        guard let cgImage = cgImage?.cropping(to: cropRect) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    func toCVPixelBuffer() -> CVPixelBuffer? {
        guard let image = cgImage else { return nil }

        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(image.width),
                                         Int(image.height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        guard status == kCVReturnSuccess else { return nil }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData,
                                width: Int(image.width),
                                height: Int(image.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: CGFloat(image.height))
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setShouldAntialias(true)
        context?.setAllowsAntialiasing(true)

        UIGraphicsPushContext(context!)
        draw(in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }

    func getCIImage() -> CIImage? {
        if let ciImage = ciImage {
            return ciImage
        } else {
            if let cgImage = cgImage {
                return CIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}
