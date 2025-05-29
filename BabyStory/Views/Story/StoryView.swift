import SwiftUI

struct StoryView: View {
    let story: Story
    var onSave: (() -> Void)? = nil
    var showSave: Bool = false
    
    var body: some View {
        ZStack {
            // Background
            AppGradientBackground()
            
            // Floating decorative elements
            FloatingStars(count: 8)
            
            ScrollView {
                VStack(spacing: 32) {
                    // Story illustration placeholder
                    AnimatedEntrance(delay: 0.2) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 200)
                                .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
                            
                            VStack(spacing: 12) {
                                Image(systemName: "book.pages.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.white)
                                
                                Text("Story Illustration")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    
                    // Story title
                    AnimatedEntrance(delay: 0.4) {
                        GradientText(
                            story.title,
                            font: .system(size: 32, weight: .bold, design: .rounded)
                        )
                        .multilineTextAlignment(.center)
                    }
                    
                    // Story content
                    AnimatedEntrance(delay: 0.6) {
                        AppCard {
                            VStack(alignment: .leading, spacing: 20) {
                                Text(story.content)
                                    .font(.title3)
                                    .lineSpacing(6)
                                    .foregroundColor(.primary)
                            }
                            .padding(24)
                        }
                    }
                    
                    // Action buttons
                    AnimatedEntrance(delay: 0.8) {
                        VStack(spacing: 16) {
                            Button(action: { /* Play narration (dummy) */ }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title2)
                                    Text("Listen to Story")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle(colors: [Color.blue, Color.purple]))
                            
                            if showSave, let onSave = onSave {
                                Button(action: onSave) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "star.fill")
                                            .font(.title3)
                                        Text("Save to Library")
                                            .font(.headline)
                                            .fontWeight(.medium)
                                    }
                                }
                                .buttonStyle(SecondaryButtonStyle())
                            }
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews
#Preview("Story View - Basic") {
    NavigationStack {
        StoryView(story: Story.mockStory)
    }
}

#Preview("Story View - With Save") {
    NavigationStack {
        StoryView(
            story: Story.mockLongStory,
            onSave: { print("Save tapped") },
            showSave: true
        )
    }
}

#Preview("Story View - Short Story") {
    NavigationStack {
        StoryView(story: Story.mockShortStory)
    }
}

// MARK: - Mock Data for Previews
extension Story {
    static var mockStory: Story {
        Story(
            id: UUID(),
            title: "The Magical Forest Adventure",
            content: """
            Once upon a time, in a magical forest filled with talking animals and glowing flowers, there lived a brave little rabbit named Luna. Luna had soft, silver fur that shimmered like moonlight and eyes as bright as stars.
            
            Every morning, Luna would hop through the enchanted woods, greeting her friends along the way. The wise old owl would hoot good morning from his tree, while the cheerful squirrels would chatter excitedly about their acorn treasures.
            
            One special day, Luna discovered a hidden path she had never seen before. The path was lined with flowers that glowed like tiny lanterns, leading deeper into the mysterious part of the forest. With courage in her heart, Luna decided to explore this magical new adventure.
            
            As she hopped along the glowing path, Luna met a friendly dragon who was no bigger than a house cat. The dragon's scales sparkled like emeralds, and his smile was warm and welcoming.
            
            "Hello, little rabbit," said the dragon. "I'm Spark, the guardian of the Crystal Cave. Would you like to see something truly magical?"
            
            Luna's eyes grew wide with wonder. Together, they ventured to a beautiful cave filled with crystals that sang the most beautiful melodies. It was the most amazing thing Luna had ever seen, and she knew this would be a day she would remember forever.
            
            From that day on, Luna and Spark became the very best of friends, and they had many more magical adventures together in their enchanted forest home.
            """,
            date: Date(),
            isFavorite: false
        )
    }
    
    static var mockLongStory: Story {
        Story(
            id: UUID(),
            title: "Princess Elena and the Kingdom of Dreams",
            content: """
            In a faraway kingdom where dreams came to life, there lived a kind princess named Elena. She had long, flowing hair that changed colors with her emotions - golden when she was happy, silver when she was thoughtful, and rainbow-colored when she was excited.
            
            Princess Elena had a very special gift: she could enter people's dreams and help make their wishes come true. Every night, she would put on her magical dream crown, which was made of stardust and moonbeams, and set off on her most important mission.
            
            One evening, Elena heard about a little boy named Marcus who lived in the village below the castle. Marcus had been having nightmares about a scary monster under his bed, and he was too frightened to sleep.
            
            Princess Elena knew she had to help. She climbed onto her flying horse, Comet, whose mane sparkled like the night sky, and together they flew down to the village. When they arrived at Marcus's house, Elena gently touched his forehead with her magical wand.
            
            Suddenly, she found herself inside Marcus's dream. The room was dark and scary, with shadows dancing on the walls. Under the bed, she could hear growling and see glowing red eyes.
            
            But Princess Elena was not afraid. She knew that sometimes scary things in dreams just needed a friend. She knelt down and gently called to the creature under the bed.
            
            "Hello there," she said in her kindest voice. "My name is Elena. What's your name?"
            
            Slowly, a fuzzy purple creature emerged from under the bed. He had big, sad eyes and looked very lonely.
            
            "I'm Grumble," he said quietly. "I didn't mean to scare Marcus. I just wanted a friend to play with, but everyone runs away when they see me."
            
            Princess Elena's heart filled with compassion. She had an idea that would help both Marcus and Grumble.
            
            With a wave of her wand, she transformed Grumble from a scary monster into a friendly, cuddly teddy bear who could still talk and play. Then she gently woke Marcus up.
            
            "Marcus," she whispered, "I have a special friend for you. His name is Grumble, and he promises to keep you safe and chase away any bad dreams."
            
            From that night on, Marcus slept peacefully with his new friend Grumble by his side. And Princess Elena continued her nightly missions, spreading kindness and turning fears into friendships throughout the Kingdom of Dreams.
            
            The end.
            """,
            date: Date().addingTimeInterval(-86400),
            isFavorite: true
        )
    }
    
    static var mockShortStory: Story {
        Story(
            id: UUID(),
            title: "The Little Star",
            content: """
            High up in the night sky lived a little star named Twinkle. She was smaller than all the other stars, but she had the biggest heart.
            
            Every night, Twinkle would shine as bright as she could to help light the way for children going to bed. She loved watching over them and making sure they felt safe and loved.
            
            One night, a little girl looked up at the sky and whispered, "Thank you, little star, for keeping me company." 
            
            Twinkle's light grew even brighter with joy, and she knew that being small didn't matter when you had a big heart full of love.
            
            And so, Twinkle continued to shine every night, knowing that she was making a difference in the world, one child at a time.
            """,
            date: Date().addingTimeInterval(-172800),
            isFavorite: false
        )
    }
}
