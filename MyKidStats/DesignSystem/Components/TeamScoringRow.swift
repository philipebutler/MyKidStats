import SwiftUI

struct TeamScoringRow: View {
    let jerseyNumber: String
    let playerName: String
    let currentScore: Int
    let onScore: (Int) -> Void

    var body: some View {
        HStack(spacing: .spacingM) {
            Text("#\(jerseyNumber)")
                .font(.body.bold())
                .foregroundColor(.secondaryText)
                .frame(width: 40, alignment: .leading)

            Text(playerName)
                .font(.teamRow)
                .lineLimit(1)

            Spacer()

            Text("\(currentScore)")
                .font(.title3.bold())
                .foregroundColor(.secondaryText)
                .frame(width: 40, alignment: .trailing)

            HStack(spacing: 4) {
                TeamScoreButton(points: 1) { onScore(1) }
                TeamScoreButton(points: 2) { onScore(2) }
                TeamScoreButton(points: 3) { onScore(3) }
            }
        }
        .padding(.vertical, .spacingS)
        .padding(.horizontal, .spacingM)
        .background(Color.cardBackground)
    }
}

struct TeamScoringRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 2) {
            TeamScoringRow(
                jerseyNumber: "4",
                playerName: "Marcus Williams",
                currentScore: 12
            ) { points in
                print("Marcus +\(points)")
            }

            TeamScoringRow(
                jerseyNumber: "12",
                playerName: "Sarah Johnson",
                currentScore: 8
            ) { points in
                print("Sarah +\(points)")
            }

            TeamScoringRow(
                jerseyNumber: "23",
                playerName: "Jordan Lee with a really long name",
                currentScore: 6
            ) { points in
                print("Jordan +\(points)")
            }
        }
        .background(Color.appBackground)
        .previewLayout(.sizeThatFits)
    }
}
