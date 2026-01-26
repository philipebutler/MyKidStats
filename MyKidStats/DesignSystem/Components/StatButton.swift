import SwiftUI

struct StatButton: View {
    let type: StatType
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(type.color)

                Text(type.displayName)
                    .font(.statLabel)
                    .foregroundColor(type.color)

                Text("\(count)")
                    .font(.statValue)
                    .foregroundColor(.secondaryText)
            }
            .frame(width: .buttonSizeFocus, height: .buttonSizeFocus)
            .background(type.color.opacity(0.15))
            .cornerRadius(.cornerRadiusButton)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadiusButton)
                    .stroke(type.color, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
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
