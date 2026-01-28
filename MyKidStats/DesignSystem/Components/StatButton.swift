import SwiftUI

struct StatButton: View {
    let type: StatType
    let count: Int
    let action: () -> Void
    
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.sizeCategory) private var sizeCategory

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(type.color)

                Text(type.displayName)
                    .font(.statLabel)
                    .foregroundColor(type.color)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Text("\(count)")
                    .font(.statValue)
                    .foregroundColor(.secondaryText)
            }
            .frame(width: .buttonSizeFocus, height: .buttonSizeFocus)
            .background(type.color.opacity(reduceTransparency ? 0.25 : 0.15))
            .cornerRadius(.cornerRadiusButton)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadiusButton)
                    .stroke(type.color, lineWidth: reduceTransparency ? 3 : 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityHint("Tap to record \(type.displayName.lowercased())")
        .accessibilityAddTraits(.isButton)
    }
    
    private var accessibilityLabelText: String {
        let statName = type.displayName
        let countDescription = count == 1 ? "1 time" : "\(count) times"
        return "\(statName), recorded \(countDescription)"
    }
}

struct StatButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Shooting Stats")
                .font(.headline)

            HStack(spacing: .spacingM) {
                StatButton(type: .twoPointMade, count: 4) {
                    print("2PT Made")
                }
                StatButton(type: .twoPointMiss, count: 3) {
                    print("2PT Miss")
                }
                StatButton(type: .threePointMade, count: 2) {
                    print("3PT Made")
                }
            }

            Text("Other Stats")
                .font(.headline)
                .padding(.top)

            HStack(spacing: .spacingM) {
                StatButton(type: .rebound, count: 5) {
                    print("Rebound")
                }
                StatButton(type: .assist, count: 3) {
                    print("Assist")
                }
                StatButton(type: .steal, count: 2) {
                    print("Steal")
                }
            }
        }
        .padding()
        .background(Color.appBackground)
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.light)

        VStack(spacing: .spacingM) {
            HStack(spacing: .spacingM) {
                StatButton(type: .twoPointMade, count: 4) { }
                StatButton(type: .rebound, count: 5) { }
                StatButton(type: .turnover, count: 1) { }
            }
            Text("Dark Mode")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
}
