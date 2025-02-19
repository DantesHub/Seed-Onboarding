struct ChallengeCard: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @Environment(\.modelContext) private var modelContext
    let challenge: Challenge
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                Text(challenge.title)
                    .font(FontManager.overUsedGrotesk(type: .bold, size: .h2))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(challenge.challengers > 2000 ? challenge.challengers : 11987) participants")
                        .font(FontManager.overUsedGrotesk(type: .medium, size: .p2))
                        .foregroundColor(.gray)
                    Text(challenge.currentStatus == "challenge completed" ? "finished" : "")
                        .font(FontManager.overUsedGrotesk(type: .medium, size: .p2))
                        .foregroundColor(.primaryBlue)
                }
                
                // ... rest of the card UI ...
            }
            // ... SplineView and other UI elements ...
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.darkPurple)
                .overlay(SharedComponents.clearShadow)
        )
        .opacity(challenge.currentStatus == "challenge completed" ? 0.5 : 1)
    }
} 