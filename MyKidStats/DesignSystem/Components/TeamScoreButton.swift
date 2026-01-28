import SwiftUI

struct TeamScoreButton: View {
    let points: Int
    let action: () -> Void
    
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        Button(action: action) {
            Text("+\(points)")
                .font(.body.bold())
                .frame(width: .buttonSizeTeam, height: .buttonSizeTeam)
                .background(Color.statTeam.opacity(reduceTransparency ? 0.25 : 0.15))
                .foregroundColor(.statTeam)
                .cornerRadius(.cornerRadiusSmall)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add \(points) point\(points == 1 ? "" : "s") to opponent score")
        .accessibilityAddTraits(.isButton)
    }
}

struct TeamScoreButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            HStack(spacing: .spacingS) {
                TeamScoreButton(points: 1) {
                    print("+1")
                }
                TeamScoreButton(points: 2) {
                    print("+2")
                }
                TeamScoreButton(points: 3) {
                    print("+3")
                }
            }

            Text("Light Mode")
                .font(.caption)
        }
        .padding()
        .background(Color.appBackground)
        .previewLayout(.sizeThatFits)

        // Dark mode
        HStack(spacing: .spacingS) {
            TeamScoreButton(points: 1) { }
            TeamScoreButton(points: 2) { }
            TeamScoreButton(points: 3) { }
        }
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
}
