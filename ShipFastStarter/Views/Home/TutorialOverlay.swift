import SwiftUI

struct NoiseEffect: ViewModifier {
    let intensity: Double

    func body(content: Content) -> some View {
        content
            .overlay(
                Color.clear
                    .overlay(
                        GeometryReader { geo in
                            Image(uiImage: generateNoiseImage(size: geo.size, intensity: intensity))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    )
            )
            .compositingGroup()
            .blendMode(.overlay)
    }

    private func generateNoiseImage(size: CGSize, intensity: Double) -> UIImage {
        let width = Int(size.width)
        let height = Int(size.height)
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        let rawData = UnsafeMutableRawPointer.allocate(byteCount: height * bytesPerRow, alignment: 8)
        defer { rawData.deallocate() }

        for y in 0 ..< height {
            for x in 0 ..< width {
                let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                let intensity = UInt8(Double.random(in: 0 ... 1) * 255 * intensity)
                rawData.storeBytes(of: intensity, toByteOffset: offset, as: UInt8.self)
                rawData.storeBytes(of: intensity, toByteOffset: offset + 1, as: UInt8.self)
                rawData.storeBytes(of: intensity, toByteOffset: offset + 2, as: UInt8.self)
                rawData.storeBytes(of: UInt8(255), toByteOffset: offset + 3, as: UInt8.self)
            }
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let provider = CGDataProvider(data: Data(bytes: rawData, count: height * bytesPerRow) as CFData),
              let cgImage = CGImage(width: width,
                                    height: height,
                                    bitsPerComponent: bitsPerComponent,
                                    bitsPerPixel: bytesPerPixel * 8,
                                    bytesPerRow: bytesPerRow,
                                    space: colorSpace,
                                    bitmapInfo: bitmapInfo,
                                    provider: provider,
                                    decode: nil,
                                    shouldInterpolate: false,
                                    intent: .defaultIntent)
        else {
            return UIImage()
        }

        return UIImage(cgImage: cgImage)
    }
}

extension View {
    func noise(intensity: Double) -> some View {
        modifier(NoiseEffect(intensity: intensity))
    }
}

import SwiftUI

struct PanicTutorialOverlay: View {
    @Binding var showTutorial: Bool
    @Binding var tutorialStep: Int
    let screenSize: CGSize

    var body: some View {
        ZStack {
            // Semi-transparent background with cutout
            Color.black.opacity(0.7)
                .mask(
                    Rectangle()
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .frame(width: screenSize.width * 0.525, height: screenSize.width * 0.6)
                                .position(x: tutorialStep == 0 ? screenSize.width * 0.25 : screenSize.width * 0.75,
                                          y: screenSize.height - (screenSize.width * 0.3 / 2) - 80)
                                .blendMode(.destinationOut)
                        )
                )
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false) // Allow taps to pass through

            // Tooltip
            VStack {
                Spacer()
                HStack {
                    if tutorialStep == 0 {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Panic Button")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Tap here when you need immediate help")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.leading, 20)
                        .padding(.bottom, screenSize.width * 0.4 + 100)
                        Spacer()
                    } else {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 10) {
                            Text("Relapse Button")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Tap here to log a relapse")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.trailing, 20)
                        .padding(.bottom, screenSize.width * 0.4 + 100)
                    }
                }
            }
        }
    }
}
