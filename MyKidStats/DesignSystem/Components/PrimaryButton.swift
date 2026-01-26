import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: .spacingM) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                }
                Text(title)
                    .font(.body.bold())
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.blue.opacity(0.15))
            .foregroundColor(.blue)
            .cornerRadius(.cornerRadiusButton)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadiusButton)
                    .stroke(Color.blue, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: .spacingL) {
            PrimaryButton(
                title: "Start Game for Alex",
                icon: "play.circle.fill"
            ) {
                print("Start game")
            }

            PrimaryButton(
                title: "Create Team"
            ) {
                print("Create team")
            }

            PrimaryButton(
                title: "Export Stats",
                icon: "square.and.arrow.up"
            ) {
                print("Export")
            }
        }
        .padding()
        .background(Color.appBackground)
        .previewLayout(.sizeThatFits)
    }
}
