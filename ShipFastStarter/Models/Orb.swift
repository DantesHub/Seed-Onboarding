//
//  Orb.swift
//  Resolved
//
//  Created by Dante Kim on 10/12/24.
//
import Foundation

enum Orb: String, CaseIterable, Comparable {
    case originalSeed = "https://build.spline.design/QPBt1WUXCXWwhfuRudi0/scene.splineswift"
    case blueOrb
    case fireDrop = "https://build.spline.design/EfK3liIASBHKyXszZehd/scene.splineswift"
    case materialBlob = "goldBlob"
    case infinityBulb = "https://build.spline.design/TI7r46DyuwQEUxLhdLbs/scene.splineswift"
    case spores = "https://build.spline.design/joYU3KwqZG0n3vl1sOlU/scene.splineswift"
    case lavalLamp = "https://build.spline.design/lROB4qkgKSzqlMt5pwLG/scene.splineswift"
    case aiSphere = "https://build.spline.design/6ZLHxtXEOUXqy4fn3bP9/scene.splineswift"
    case marbleDyson = "https://build.spline.design/EViKlOGzsaMUHdV42StT/scene.splineswift"
    
    // reward orbs
    case winterArc = "winterArc"
    case earth = "https://build.spline.design/jWl5PP30-PKtk2ywXYxa/scene.splineswift"
    case bluePlanet = "https://build.spline.design/ZdY7ZNA6TAMaIJKf1wyN/scene.splineswift"
    case nut
    
    func daysCount() -> Int {
        switch self {
        case .blueOrb: return 3
        case .fireDrop: return 7
        case .materialBlob: return 14
        case .infinityBulb: return 21
        case .spores: return 30
        case .lavalLamp: return 45
        case .aiSphere: return 60
        case .marbleDyson: return 90

        default:
            return 0
        }
    }

    static func mainOrbs() -> [Orb] {
        return [.originalSeed, .blueOrb, .fireDrop, .materialBlob, .infinityBulb, .spores, .lavalLamp, .aiSphere, .marbleDyson]
    }

    static func rewardOrbs() -> [Orb] {
        return [.winterArc, .earth, .bluePlanet, .nut]
    }

    func name() -> String {
        return String(describing: self)
    }

    func displayName() -> String {
        switch self {
        case .originalSeed: return "Origin Seed"
        case .blueOrb: return "Blue Origin"
        case .fireDrop: return "The Resilient"
        case .materialBlob: return "The Challenger"
        case .infinityBulb: return "The Visionary"
        case .spores: return "The Reborn"
        case .lavalLamp: return "The Shield-Bearer"
        case .aiSphere: return "The Pathfinder"
        case .marbleDyson: return "The Champion"
        case .nut: return "The Nut"
        case .earth: return "The Earth"
        case .bluePlanet: return "The Blue Earth"
        case .winterArc: return "Winter Arc Globe"
        }
    }

    static func getPreviousSeeds(currentSeed: String) -> [String] {
        let allSeeds = [
            "originalSeed",
            "blueOrb",
            "fireDrop",
            "materialBlob",
            "infinityBulb",
            "spores",
            "lavalLamp",
            "aiSphere",
            "marbleDyson",
        ]

        guard let currentIndex = allSeeds.firstIndex(of: currentSeed) else {
            return []
        }

        return Array(allSeeds[0 ... currentIndex])
    }

    // New function to compare orbs
    static func < (lhs: Orb, rhs: Orb) -> Bool {
        let order: [Orb] = [.originalSeed, .blueOrb, .fireDrop, .materialBlob, .infinityBulb, .spores, .lavalLamp, .aiSphere, .marbleDyson]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs)
        else {
            return false
        }
        return lhsIndex < rhsIndex
    }

    // Add this new function
    func nextTwoOrbs() -> [Orb] {
        let allOrbs = Orb.allCases
        guard let currentIndex = allOrbs.firstIndex(of: self) else {
            return []
        }

        let nextIndex = currentIndex + 1
        let nextNextIndex = currentIndex + 2

        var result: [Orb] = []

        if nextIndex < allOrbs.count {
            result.append(allOrbs[nextIndex])
        }

        if nextNextIndex < allOrbs.count {
            result.append(allOrbs[nextNextIndex])
        }

        return result
    }

    // New function to return the time to nurture for each orb
    func timeToNurture() -> String {
        switch self {
        case .originalSeed:
            return "24 hours"
        case .blueOrb:
            return "3 days"
        case .fireDrop:
            return "7 days"
        case .materialBlob:
            return "14 days"
        case .infinityBulb:
            return "21 days"
        case .spores:
            return "30 days"
        case .lavalLamp:
            return "45 days"
        case .aiSphere:
            return "60 days"
        case .marbleDyson:
            return "90 days"
        case .nut:
            return "15+ days in Novemeber"
        case .earth:
            return "50 reflections"
        case .winterArc:
            return "50 total sober days"
        case .bluePlanet:
            return "Complete all rewire tapes"
        }
    }

    func motivationalContent() -> String {
        switch self {
        case .originalSeed:
            return "Enhanced mental clarity, self-esteem, and relationships."
        case .blueOrb:
            return "Three days in. Every step strengthens your resolve."
        case .fireDrop:
            return "One week down! Your mind, body and aura are beginning to be set ablaze."
        case .materialBlob:
            return "Two weeks in. You're in the 5th percentile of all users."
        case .infinityBulb:
            return "21 days – a habit is forming. You're seeing the world with new clarity and purpose."
        case .spores:
            return "A full month of dedication. You've transformed, reclaiming your energy and purpose."
        case .lavalLamp:
            return "You've built a fortress within, standing firm against old habits. Your strength is now a part of who you are."
        case .aiSphere:
            return "Two months without looking back. You're paving your path forward with clarity and confidence."
        case .marbleDyson:
            return "Three months of resilience and transformation. You've reached a new peak, wearing the crown of a true champion."
        case .nut:
            return "Complete the challenge millions partake in November. This orb reflects that you're in top 1% of all users."
        case .earth:
            return "50 reflections. You've built a strong foundation for your new life."
        case .bluePlanet:
            return "You've rewired your brain and have all the tools you need to stay on this path."
        case .winterArc:
            return "You're taking this winter season to claim back your life and unleash your true potential."
        }
    }

    func benefits() -> [String] {
        switch self {
        case .originalSeed:
            return [
                "Reduced Shame and Guilt: A quick mental boost as you feel empowered by the decision to take control.",
                "Increased Dopamine Sensitivity: Even one day away from overstimulation begins to help the brain reset.",
                "Improved Focus: Initial improvements in concentration, as your brain is freed from habitual distractions.",
            ]
        case .blueOrb:
            return [
                "Reduced Stress and Anxiety: Studies show that even a short break can lower cortisol levels and promote relaxation.",
                "Improved Mental Clarity: Early reductions in brain fog lead to sharper focus on tasks.",
                "Better Mood Stability: A more balanced mood as dopamine begins to stabilize without constant artificial highs.",
            ]
        case .fireDrop:
            return [
                "Improved Energy Levels: Reduced reliance on dopamine surges leads to steadier energy throughout the day.",
                "Early Reversal of P.E.D. Symptoms: Initial improvements in sexual response for some individuals as the brain rewires.",
                "Enhanced Sleep Quality: A week of better sleep patterns, as research shows that avoiding overstimulation can improve sleep cycles.",
            ]
        case .materialBlob:
            return [
                "Lower Anxiety Levels: Abstaining from porn has been shown to reduce anxiety, allowing you to approach life with greater calm.",
                "Better Interpersonal Connections: Improved empathy and presence with others, as overstimulation no longer numbs social cues.",
                "Improved Self-Confidence: Building trust in yourself by maintaining control over impulses reinforces self-esteem.",
            ]
        case .infinityBulb:
            return [
                "Increased Dopamine Receptors: Your brain is adapting, improving its ability to experience pleasure naturally.",
                "Strengthened Willpower: Consistent progress builds mental resilience, making it easier to resist urges.",
                "Deeper Sense of Purpose: Many report feeling more in touch with their goals and values, improving motivation and drive.",
            ]
        case .spores:
            return [
                "Improved Sexual Health: Many individuals notice significant improvements in P.E.D. symptoms as their brain rewires.",
                "Better Overall Mood: A month of abstaining helps stabilize dopamine, reducing mood swings and boosting happiness.",
                "Enhanced Cognitive Function: Research suggests improved focus, problem-solving, and mental clarity after extended periods of abstinence.",
            ]
        case .lavalLamp:
            return [
                "Reduced Cravings: Research shows that cravings decrease over time as the brain adjusts.",
                "Increased Physical Stamina: Many report improvements in physical fitness and stamina as energy levels stabilize.",
                "Improved Social Skills: Many report enhanced social interactions and empathy as the emotional numbing of overstimulation fades.",
            ]
        case .aiSphere:
            return [
                "Reduced Symptoms of Depression: Studies suggest decreased depressive symptoms due to balanced dopamine levels and healthier habits.",
                "Improved Romantic Relationships: Better intimacy, communication, and connection with partners as emotional clarity increases.",
                "Increased Motivation and Drive: A consistent sense of accomplishment fuels motivation to tackle other challenges in life.",
            ]
        case .marbleDyson:
            return [
                "Rewiring of Neural Pathways: Studies suggest three months can significantly change the brain's reward circuitry, leading to long-lasting changes in habits and behaviors.",
                "Increased Emotional Resilience: Many report an enhanced ability to manage stress and emotions without falling back on old coping mechanisms.",
                "Greater Overall Well-being: With consistent abstention, many feel more fulfilled, confident, and in control, leading to a deeper sense of satisfaction with life.",
            ]
        case .nut:
            return [
                "Reduced Cravings: Research shows that cravings decrease over time as the brain adjusts.",
                "Increased Physical Stamina: Many report improvements in physical fitness and stamina as energy levels stabilize.",
                "Improved Social Skills: Many report enhanced social interactions and empathy as the emotional numbing of overstimulation fades.",
            ]
        case .earth:
            return [
                "Stronger mental clarity",
                "Greater sense of purpose",
                "Increased motivation",
            ]
        case .winterArc:
            return [
                "Increased mental strength",
                "Increased mental clarity",
                "50+% increase in motivation",
                "50-% debuff to triggers",
            ]
        
        case .bluePlanet:
            return [
                "90% less likely to relapse",
                "Much less likely to think about porn",
                "Improved clarity, and focus.",
            ]
        }
    }

    func benefitsSummary() -> [String] {
        return benefits().map { benefit in
            if let colonIndex = benefit.firstIndex(of: ":") {
                return String(benefit[..<colonIndex])
            }
            return benefit
        }
    }

    static func getURL(forName name: String) -> String? {
        switch name {
        case "originalSeed": return Orb.originalSeed.rawValue
        case "blueOrb": return Orb.blueOrb.rawValue
        case "fireDrop": return Orb.fireDrop.rawValue
        case "materialBlob": return Orb.materialBlob.rawValue
        case "infinityBulb": return Orb.infinityBulb.rawValue
        case "spores": return Orb.spores.rawValue
        case "lavalLamp": return Orb.lavalLamp.rawValue
        case "aiSphere": return Orb.aiSphere.rawValue
        case "marbleDyson": return Orb.marbleDyson.rawValue
        case "nut": return Orb.nut.rawValue
        case "earth": return Orb.earth.rawValue
        case "bluePlanet": return Orb.bluePlanet.rawValue
        case "winterArc": return Orb.winterArc.rawValue
        default: return nil
        }
    }

    static func getOrb(forName name: String) -> Orb {
        switch name {
        case "originalSeed": return Orb.originalSeed
        case "blueOrb": return Orb.blueOrb
        case "fireDrop": return Orb.fireDrop
        case "materialBlob": return Orb.materialBlob
        case "infinityBulb": return Orb.infinityBulb
        case "spores": return Orb.spores
        case "lavalLamp": return Orb.lavalLamp
        case "aiSphere": return Orb.aiSphere
        case "marbleDyson": return Orb.marbleDyson
        case "nut": return Orb.nut
        case "earth": return Orb.earth
        case "bluePlanet": return Orb.bluePlanet
        case "winterArc": return Orb.winterArc
        default: return .originalSeed
        }
    }

    static func calculateProgress(startDate: Date) -> Double {
        let currentDate = Date()
        let elapsedTime = currentDate.timeIntervalSince(startDate) / 3600 // Convert to hours

        let milestones = [
            72.0, // 3 days
            168.0, // 7 days
            336.0, // 14 days
            504.0, // 21 days
            720.0, // 30 days
            1080.0, // 45 days
            1440.0, // 60 days
            2160.0, // 90 days
        ]

        if elapsedTime >= milestones.last! {
            return 1.0 // 100% progress if beyond the last milestone
        }

        for (index, milestone) in milestones.enumerated() {
            if elapsedTime < milestone {
                let previousMilestone = index > 0 ? milestones[index - 1] : 0
                let progressInCurrentStage = (elapsedTime - previousMilestone) / (milestone - previousMilestone)
                return progressInCurrentStage
            }
        }

        return 0.0 // This should never be reached, but Swift requires a return statement
    }
}

enum OrbSize: CGFloat {
    case extraSmall = 101
    case small = 125
    case medium = 175
    case large = 225
    case extraLarge = 275
    case XXL = 375
    case XXXL = 450
    case full = 600
}
