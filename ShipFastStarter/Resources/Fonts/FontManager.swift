//
//  FontManager.swift
//  FitCheck
//
//  Created by Dante Kim on 11/2/23.
//

import SwiftUI

enum FontManager {
    static func defaultFont(size: CGFloat) -> Font {
        return .system(size: size, weight: .medium)
    }

    static func heading1(size: CGFloat = 24) -> Font {
        return .system(size: size, weight: .bold)
    }

    static func body1(size: CGFloat = 16) -> Font {
        return Font.custom("ClashDisplay-Medium", size: size)
    }

    static func sfPro(type: ClashType, size: FontSize) -> Font {
        switch type {
        case .regular: return Font.custom("SF Pro", size: size.rawValue)
        case .medium: return Font.custom("ClashDisplay-Medium", size: size.rawValue)
        case .semibold: return Font.custom("ClashDisplay-Semibold", size: size.rawValue)
        case .bold: return Font.custom("ClashDisplay-Bold", size: size.rawValue)
        case .light: return Font.custom("ClashDisplay-Light", size: size.rawValue)
        case .extraLight: return Font.custom("ClashDisplay-Extralight", size: size.rawValue)
        }
    }

    static func overUsedGrotesk(type: OverusedType, size: FontSize) -> Font {
        switch type {
        case .medium: return Font.custom("OverusedGrotesk-Medium", size: size.rawValue)
        case .bold: return Font.custom("OverusedGrotesk-Bold", size: size.rawValue)
        case .light: return Font.custom("OverusedGrotesk-Light", size: size.rawValue)
        case .black:
            return Font.custom("OverusedGrotesk-Black", size: size.rawValue)
        case .book:
            return Font.custom("OverusedGrotesk-Book", size: size.rawValue)
        case .extraBold:
            return Font.custom("OverusedGrotesk-ExtraBold", size: size.rawValue)
        case .roman:
            return Font.custom("OverusedGrotesk-Roman", size: size.rawValue)
        case .semiBold:
            return Font.custom("OverusedGrotesk-SemiBold", size: size.rawValue)
        }
    }
    // Add other custom styles as needed
}

enum ClashType {
    case regular
    case medium
    case semibold
    case bold
    case light
    case extraLight
}

enum OverusedType {
    case black
    case bold
    case book
    case extraBold
    case light
    case medium
    case roman
    case semiBold

    static func from(_ weight: Font.Weight) -> OverusedType {
        switch weight {
        case .black: return .black
        case .bold: return .bold
        case .medium: return .medium
        case .light: return .light
        case .semibold: return .semiBold
        default: return .book
        }
    }
}

enum FontSize: CGFloat {
    case h1Big = 40
    case h1Medium = 36
    case h1 = 32
    case h2Big = 28
    case h2 = 24
    case h3 = 22
    case h3p1 = 20
    case p2 = 18
    case p3 = 14
    case p4 = 12
    case p7 = 11
    case p6 = 10
    case p5 = 17
    case title = 48
    case huge = 56
    case titleHuge = 72
    case titlebold = 64
    case statNumber = 92
    case titleNumber = 116
    case titleHundred = 100
    case titleMedium = 164
    case titleLarge = 190
}

extension View {
    func defaultFont(size: CGFloat) -> some View {
        font(FontManager.defaultFont(size: size))
    }

    func heading1() -> some View {
        font(FontManager.heading1())
    }

    func body1() -> some View {
        font(FontManager.body1())
    }

    func sfFont(weight: Font.Weight, size: FontSize) -> some View {
        font(.system(size: size.rawValue, weight: weight))
    }

    func overusedFont(weight: OverusedType, size: FontSize) -> some View {
        font(FontManager.overUsedGrotesk(type: weight, size: size))
    }
}
