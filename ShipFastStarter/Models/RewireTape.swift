//
//  RewireTape.swift
//  Resolved
//
//  Created by Dante Kim on 10/28/24.
//

import Foundation

struct RewireTape: Codable {
    var id: Int
    var title: String
    var focus: String
    var description: String
    var coverImage: String
    var audioURL: String
    var usersCompleted: Int = 0

    init(id: Int, title: String, description: String, focus: String, coverImage: String, audioURL: String) {
        self.id = id
        self.title = title
        self.description = description
        self.focus = focus
        self.coverImage = coverImage
        self.audioURL = audioURL
    }

    static var tapes: [RewireTape] = [
        RewireTape(id: 1, title: "The Introduction", description: "This introduction equips you with the proper mental frameworks and strategies for using and implementing the SEED rewiring tapes collection. You will understand how the collection has been engineered. And you will learn how to use the tapes in the most effective way.", focus: "Self-Awareness and Acceptance", coverImage: "tape1", audioURL: "tape1"),
        RewireTape(id: 2, title: "The Enchanted Safe", description: "Introduces a few methods that will be used for clearing the mind, becoming more present, and entering the appropriate brain state.  There may be times where you think you are confused; that’s good. You will walk away feeling excited for what’s next.", focus: "Understanding Origins and Influences", coverImage: "tape2", audioURL: "tape2"),
        RewireTape(id: 3, title: "Vibrational Resonance", description: "This training uses previously learned material to continue learning how to enter into the appropriate brain state.  You will learn a breathing exercise that calibrates your vibrational resonance. You will learn how to release stale stored up energy in the body, and replenish yourself with clean and fresh, new energy.", focus: "Increasing vibes", coverImage: "tape3", audioURL: "tape3"),

        RewireTape(id: 4, title: "Protective Energy Vortex (PEV)", description: "Here, you will learn how to transmute energy from your retained seed into a vortex that not only protects you from unwanted energy exposure, but also helps you maintain clean internal energy in your day to day.", focus: "Building Mental Resilience", coverImage: "tape4", audioURL: "tape4"),
        RewireTape(id: 5, title: "Self-Mastery", description: "This tape brings everything you have learned into a final self-mastery procedure where you will be able to do everything you have learned all by yourself.", focus: "", coverImage: "tape5", audioURL: "tape5"),
//        RewireTape(id: 6, title: "Embracing the Higher Self", description: "Users reflect on their core values and higher purpose, drawing strength from what truly matters to them. This tape encourages alignment with their goals and faith (if applicable) to reinforce their commitment.", focus: "Mastery Tape", coverImage: "tape6", audioURL: "tape6"),
//        RewireTape(id: 7, title: "Forging Strength in Vulnerability", description: "This tape addresses the inevitable moments of vulnerability and potential relapse. It helps users accept setbacks as part of the journey, teaching them to reach out for support and learn from these experiences rather than feeling defeated.", focus: "Mastery Tape", coverImage: "tape7", audioURL: "tape 7"),
//        RewireTape(id: 8, title: "The Journey Beyond", description: "The final tape prepares users for life beyond the app, encouraging them to continue their journey of growth. It emphasizes celebrating progress, maintaining resilience, and integrating new insights and practices into daily life.", focus: "Mastery Tape", coverImage: "tape8", audioURL: "tape 8")
    ]
}
