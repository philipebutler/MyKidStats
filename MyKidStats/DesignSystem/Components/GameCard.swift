import SwiftUI

struct GameCard: View {
    let teamName: String
    let opponentName: String
    let teamScore: Int
    let opponentScore: Int
    let gameDate: Date
    let result: GameResult
    let focusPlayerStats: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: .spacingS) {
                HStack {
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                    Spacer()
                    Text(result.emoji)
                        .font(.title3)
                }

                Text("\(teamName) \(teamScore), \(opponentName) \(opponentScore)")
                    .font(.body.bold())
                    .foregroundColor(.primaryText)

                if !focusPlayerStats.isEmpty {
                    Text(focusPlayerStats)
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(.cornerRadiusCard)
        }
        .buttonStyle(.plain)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: gameDate)
    }
}

struct GameCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: .spacingL) {
            GameCard(
                teamName: "Warriors",
                opponentName: "Eagles",
                teamScore: 52,
                opponentScore: 45,
                gameDate: Date(),
                result: .win,
                focusPlayerStats: "Alex: 12 PTS, 5 REB, 3 AST",
                action: { print("Tapped") }
            )

            GameCard(
                teamName: "Warriors",
                opponentName: "Tigers",
                teamScore: 48,
                opponentScore: 55,
                gameDate: Date().addingTimeInterval(-86400 * 7),
                result: .loss,
                focusPlayerStats: "Alex: 8 PTS, 4 REB, 2 AST",
                action: { print("Tapped") }
            )
        }
        .padding()
        .background(Color.appBackground)
        .previewLayout(.sizeThatFits)
    }
}
