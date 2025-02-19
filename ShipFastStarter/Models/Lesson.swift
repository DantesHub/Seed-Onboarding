import SwiftUI

struct Lesson: Identifiable {
    let id: Int
    let title: String
    let slides: [SlideContent]
    let img: Image
    let exercise: String

    init(id: Int, title: String, slides: [SlideContent], img: Image, exercise: String) {
        self.id = id
        self.title = title
        self.slides = slides
        self.img = img
        self.exercise = exercise
    }

    struct SlideContent {
        let number: Int
        let type: String
        let emoji: String
        let subtext1: String
        let subtext2: String
    }

    static var lessons: [Lesson] = [
        Lesson(id: 1, title: "Understanding Your Why", slides: [
            SlideContent(
                number: 1,
                type: "text",
                emoji: "💡",
                subtext1: "Changing your life can be tough. When we decide that this change is necessary, the first step is to understand why we want to change and realize how this issue is impacting our life",
                subtext2: "At first glance, the answer may seem obvious. But a problem thoroughly understood can be sometimes completely solved."
            ),
            SlideContent(
                number: 2,
                type: "text",
                emoji: "🤔",
                subtext1: "Envision your life 5-10 years from now. Consider how your current behavior might affect your key relationships – with companions, family, and most importantly, yourself.",
                subtext2: "Is the future outlook acceptable if we leave things unchanged?"

            ),
            SlideContent(
                number: 3,
                type: "text",
                emoji: "💡",
                subtext1: "By defining your values, you give meaning to your life and to the goals you pursue. By having a clear definition, a sort of internal compass, you help yourself act consistently and with purpose.",
                subtext2: "So ask yourself, what is the main reason for you to be here?. Why is this important to you?\nContinue to ask, why is that important?\nUntil you get to the bottom, most underlying reason, keep asking yourself, why?"
            ),
            SlideContent(
                number: 4,
                type: "action",
                emoji: "",
                subtext1: "Now, write down why you must absolutely quit porn",
                subtext2: ""
            ),
        ], img: Image(.lightBulb), exercise: "Your Why"),
        Lesson(id: 2, title: "The Neuroscience of Addiction", slides: [
            SlideContent(
                number: 1,
                type: "text",
                emoji: "🧠",
                subtext1: "Addiction is not just a matter of willpower. It's a complex interplay of brain chemistry, neural pathways, and learned behaviors.",
                subtext2: "Understanding the science behind addiction can help us approach recovery with more empathy and effective strategies."
            ),
            SlideContent(
                number: 2,
                type: "text",
                emoji: "🎭",
                subtext1: "Porn addiction hijacks the brain's reward system, flooding it with dopamine. Over time, this can lead to desensitization and the need for more extreme content to achieve the same 'high'.",
                subtext2: "This process is similar to what happens in substance addictions, affecting areas like the prefrontal cortex and limbic system."
            ),
            SlideContent(
                number: 3,
                type: "text",
                emoji: "🔄",
                subtext1: "The good news is that the brain is plastic - it can change and heal. Through abstinence and healthy behaviors, we can rewire our neural pathways.",
                subtext2: "This process takes time and patience, but it's backed by scientific evidence."
            ),
        ], img: Image(.brain), exercise: ""),

        Lesson(id: 3, title: "Identifying Triggers", slides: [
            SlideContent(
                number: 1,
                type: "text",
                emoji: "🎯",
                subtext1: "Triggers are internal or external cues that spark the urge to engage in addictive behavior. Recognizing your personal triggers is a crucial step in recovery.",
                subtext2: "Triggers can be emotional states, specific situations, or even certain times of day."
            ),
            SlideContent(
                number: 2,
                type: "text",
                emoji: "📝",
                subtext1: "Start by keeping a journal of when you feel the urge to view porn. Note the time, place, and what you were feeling or doing just before.",
                subtext2: "Look for patterns in your entries. These patterns can reveal your personal triggers."
            ),
            SlideContent(
                number: 3,
                type: "action",
                emoji: "🔍",
                subtext1: "List your top 3 triggers and brainstorm healthy alternative actions for each.",
                subtext2: ""
            ),
        ], img: Image(.target), exercise: "Triggers"),

        Lesson(id: 4, title: "Building Healthy Coping Mechanisms", slides: [
            SlideContent(
                number: 1,
                type: "text",
                emoji: "🏋️",
                subtext1: "Addiction often serves as a coping mechanism for stress, anxiety, or other negative emotions. To recover, we need to replace this unhealthy coping mechanism with healthier alternatives.",
                subtext2: "Healthy coping mechanisms can include exercise, meditation, creative pursuits, or social connection."
            ),
            SlideContent(
                number: 2,
                type: "text",
                emoji: "🧘",
                subtext1: "Mindfulness and meditation can be powerful tools. They help us observe our urges without acting on them, and can reduce stress and anxiety.",
                subtext2: "Even a few minutes of daily practice can make a significant difference."
            ),
            SlideContent(
                number: 3,
                type: "text",
                emoji: "🤝",
                subtext1: "Social connection is another crucial aspect. Isolation often fuels addiction, while healthy relationships can support recovery.",
                subtext2: "Consider joining support groups or reaching out to trusted friends and family."
            ),
        ], img: Image(.dumbbell), exercise: ""),

        Lesson(id: 5, title: "Rewiring Your Reward System", slides: [
            SlideContent(
                number: 1,
                type: "text",
                emoji: "🔀",
                subtext1: "Addiction changes our brain's reward system, making porn the go-to source for pleasure. Recovery involves rewiring this system to find joy in healthier activities.",
                subtext2: "This process takes time, but each small victory reinforces new, healthier neural pathways."
            ),
            SlideContent(
                number: 2,
                type: "text",
                emoji: "🎉",
                subtext1: "Celebrate small wins. Every time you resist an urge or engage in a healthy activity instead, you're strengthening new neural connections.",
                subtext2: "Consider setting up a reward system for yourself to reinforce positive behaviors."
            ),
            SlideContent(
                number: 3,
                type: "action",
                emoji: "📊",
                subtext1: "Create a 'pleasure inventory'. List activities that bring you joy or satisfaction, no matter how small.",
                subtext2: "Try to engage in at least one of these activities daily."
            ),
        ], img: Image(.neuron), exercise: "Rewiring"),

        Lesson(id: 6, title: "Managing Relapse", slides: [
            SlideContent(
                number: 1,
                type: "text",
                emoji: "🔁",
                subtext1: "Relapse is often part of the recovery process. It's not a failure, but an opportunity to learn and strengthen your resolve.",
                subtext2: "Understanding this can help reduce shame and increase the likelihood of getting back on track quickly."
            ),
            SlideContent(
                number: 2,
                type: "text",
                emoji: "📈",
                subtext1: "If relapse occurs, conduct a thorough analysis. What led to it? What can you learn from this experience?",
                subtext2: "Use this information to refine your recovery strategy and prevent future relapses."
            ),
            SlideContent(
                number: 3,
                type: "text",
                emoji: "🦸",
                subtext1: "Remember, recovery is not about perfection, but progress. Each day you resist is a victory, regardless of past slip-ups.",
                subtext2: "Be kind to yourself and focus on the overall trend of your journey, not individual setbacks."
            ),
        ], img: Image(.reset), exercise: ""),

        Lesson(id: 7, title: "Envisioning Your Future Self", slides: [
            SlideContent(
                number: 1,
                type: "text",
                emoji: "🔮",
                subtext1: "Visualizing your future self is a powerful tool for motivation and change. It helps create a roadmap for personal growth and recovery.",
                subtext2: "By clearly imagining who you want to become, you're more likely to make choices that align with that vision."
            ),
            SlideContent(
                number: 2,
                type: "text",
                emoji: "🌟",
                subtext1: "Think about your ideal self 5 years from now. What does your life look like? How do you feel? What have you accomplished?",
                subtext2: "Consider all aspects: relationships, career, health, personal growth, and how overcoming this challenge has shaped you."
            ),
            SlideContent(
                number: 3,
                type: "text",
                emoji: "🧭",
                subtext1: "Your future self isn't just a distant dream - it's shaped by the choices you make today. Each step towards recovery is a step towards becoming that person.",
                subtext2: "Remember, change is a process. Celebrate every small victory along the way."
            ),
            SlideContent(
                number: 4,
                type: "action",
                emoji: "📝",
                subtext1: "Write a letter to your present self from your future self. Describe the positive changes you've experienced and the obstacles you've overcome.",
                subtext2: "Keep this letter as a source of inspiration and a reminder of what you're working towards."
            ),
        ], img: Image(.futureSelf), exercise: "Letter from Future Self"),
    ]
    static var relapseRecoveryLessons: [Lesson] = [
        Lesson(id: -2, title: "Strengthening Your Resolve", slides: [
            SlideContent(
                number: 1,
                type: "text",
                emoji: "💪",
                subtext1: "Every challenge is an opportunity to grow stronger. This relapse can be a turning point in your recovery journey.",
                subtext2: "Use this experience to reinforce your commitment to change."
            ),
            SlideContent(
                number: 2,
                type: "text",
                emoji: "🎯",
                subtext1: "Revisit your reasons for wanting to quit. How has this relapse reinforced those reasons?",
                subtext2: "Your 'why' is your most powerful motivator. Let it fuel your determination."
            ),
            SlideContent(
                number: -3,
                type: "action",
                emoji: "📝",
                subtext1: "Write a letter to yourself about why this recovery is important to you. Be specific and heartfelt.",
                subtext2: "Keep this letter for times when you need motivation."
            ),
        ], img: Image(.dumbbell), exercise: "Motivation Letter"),

        Lesson(id: -3, title: "Refining Your Trigger Management", slides: [
            SlideContent(
                number: 1,
                type: "text",
                emoji: "🎯",
                subtext1: "Triggers are the sparks that ignite urges. By managing them effectively, we can prevent many relapses.",
                subtext2: "Each relapse provides valuable data about our triggers and how to handle them."
            ),
            SlideContent(
                number: 2,
                type: "text",
                emoji: "🛠️",
                subtext1: "Based on your recent experience, what new triggers have you identified? How can you prepare for them in the future?",
                subtext2: "Remember, preparation is key in managing triggers effectively."
            ),
            SlideContent(
                number: 3,
                type: "action",
                emoji: "📝",
                subtext1: "Create a detailed plan for handling your top three triggers. Include specific actions and alternatives.",
                subtext2: "The more specific your plan, the more effective it will be."
            ),
        ], img: Image(.target), exercise: "Trigger Action Plan"),

        Lesson(id: -4, title: "Building a Stronger Support System", slides: [
            SlideContent(
                number: 1,
                type: "text",
                emoji: "🤝",
                subtext1: "Recovery is not a solitary journey. A strong support system can make all the difference.",
                subtext2: "Who are the people who support your recovery? How can you lean on them more effectively?"
            ),
            SlideContent(
                number: 2,
                type: "text",
                emoji: "📞",
                subtext1: "Consider reaching out to someone you trust about your relapse. Sharing can reduce shame and increase accountability.",
                subtext2: "Remember, vulnerability is strength, not weakness."
            ),
            SlideContent(
                number: 3,
                type: "action",
                emoji: "📝",
                subtext1: "List three ways you can strengthen your support system this week. This could include joining a support group, scheduling regular check-ins with a friend, or seeking professional help.",
                subtext2: "Take action on at least one of these this week."
            ),
        ], img: Image(.supportGroup), exercise: "Support System Strengthening"),

        Lesson(id: -5, title: "Cultivating Self-Compassion", slides: [
            SlideContent(
                number: 1,
                type: "text",
                emoji: "❤️",
                subtext1: "Self-compassion is crucial in recovery. Treat yourself with the same kindness you'd offer a friend who's struggling.",
                subtext2: "Remember, you are not your addiction. You are a person worthy of love and respect, including from yourself."
            ),
            SlideContent(
                number: 2,
                type: "text",
                emoji: "🧘",
                subtext1: "Practice this self-compassion meditation: 'May I be kind to myself in this moment. May I give myself the compassion I need.'",
                subtext2: "Repeat this whenever you notice self-critical thoughts."
            ),
            SlideContent(
                number: 3,
                type: "action",
                emoji: "📝",
                subtext1: "Write down three self-compassionate statements to counter your most common self-critical thoughts.",
                subtext2: "Practice saying these to yourself regularly, especially when you're struggling."
            ),
        ], img: Image(.meditation), exercise: "Self-Compassion Statements"),

        Lesson(id: -6, title: "Reinforcing Healthy Habits", slides: [
            SlideContent(
                number: 1,
                type: "text",
                emoji: "🌱",
                subtext1: "Recovery is as much about building new, healthy habits as it is about breaking old ones.",
                subtext2: "What healthy habits have you been neglecting that you can recommit to?"
            ),
            SlideContent(
                number: 2,
                type: "text",
                emoji: "⏰",
                subtext1: "Small, consistent actions create big changes over time. Focus on daily habits that support your recovery.",
                subtext2: "This could include meditation, exercise, journaling, or connecting with supportive people."
            ),
            SlideContent(
                number: 3,
                type: "action",
                emoji: "📝",
                subtext1: "Choose one healthy habit to focus on this week. Break it down into a small, daily action you can commit to.",
                subtext2: "Track your progress and celebrate your consistency, no matter how small the action."
            ),
        ], img: Image(.gardening), exercise: "Healthy Habit Commitment"),

        Lesson(id: -7, title: "Reframing Your Recovery Journey", slides: [
            SlideContent(
                number: 1,
                type: "text",
                emoji: "🌈",
                subtext1: "Recovery isn't a straight line. It's a journey with ups and downs, each teaching valuable lessons.",
                subtext2: "How can you reframe this relapse as a step forward in your overall journey?"
            ),
            SlideContent(
                number: 2,
                type: "text",
                emoji: "🔍",
                subtext1: "Look at your progress over time, not just this moment. What positive changes have you made since starting your recovery?",
                subtext2: "Acknowledge and celebrate these changes, no matter how small."
            ),
            SlideContent(
                number: 3,
                type: "action",
                emoji: "📝",
                subtext1: "Create a 'recovery timeline' noting key milestones, lessons learned, and positive changes you've experienced.",
                subtext2: "Include this relapse as a learning opportunity. How will it propel you forward?"
            ),
        ], img: Image(.mapAndCompass), exercise: "Recovery Timeline"),
    ]

//    Lesson(id: 2, title: "Understanding Your Why", slides: [
//        SlideContent(
//            number: 1,
//            type: "text",
//            emoji: "💡",
//            subtext1: "Changing your life can be tough. When we decide that this change is necessary, the first step is to understand why we want to change and realize how this issue is impacting our life",
//            subtext2: "At first glance, the answer may seem obvious. But a problem thoroughly understood can be sometimes completely solved."
//        ),
//        SlideContent(number: 2, type: "text", emoji: "🤔", subtext1: "Envision your life 5-10 years from now. Consider how your current behavior might affect your key relationships – with friends, family, and most importantly, yourself.", subtext2: "Is the future outlook acceptable if we leave things unchanged?")
//    ], img: Image(.lightBulb))

    static var defaultLesson: Lesson {
        return Lesson(id: 0, title: "Default Lesson", slides: [
            SlideContent(
                number: 0,
                type: "text",
                emoji: "⚠️",
                subtext1: "No lessons available.",
                subtext2: "Please add some lessons to the list."
            ),
        ], img: Image(.lightBulb), exercise: "")
    }
}
