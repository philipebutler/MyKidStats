import SwiftUI
import CoreData

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: .spacingXXL) {
                    smartStartSection

                    if let lastGame = viewModel.lastGame {
                        lastGameSection(lastGame)
                    }

                    if !viewModel.recentActivities.isEmpty {
                        recentActivitySection
                    }
                }
                .padding(.spacingL)
            }
            .background(Color.appBackground)
            .navigationTitle("Basketball Stats")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.openSettings) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }

    private var smartStartSection: some View {
        VStack(alignment: .leading, spacing: .spacingL) {
            Text("Ready for today's game?")
                .font(.title2)

            if let defaultChild = viewModel.defaultChild {
                PrimaryButton(
                    title: "Start Game for \(defaultChild.name ?? "")",
                    icon: "play.circle.fill"
                ) {
                    viewModel.startGame(for: defaultChild)
                }

                if viewModel.hasMultipleChildren {
                    Button(action: viewModel.toggleChild) {
                        HStack {
                            Text("Switch to \(viewModel.otherChildName)")
                            Image(systemName: "arrow.right")
                        }
                        .font(.body)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(.cornerRadiusButton)
                    }
                }
            } else {
                VStack(spacing: .spacingL) {
                    Text("Let's get started!")
                        .font(.headline)

                    Text("Add a child to start tracking their basketball stats.")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)

                    PrimaryButton(
                        title: "Add Your First Child",
                        icon: "plus.circle.fill"
                    ) {
                        viewModel.showAddChild()
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(.cornerRadiusCard)
            }
        }
    }

    private func lastGameSection(_ game: Game) -> some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Last Game:")
                .font(.headline)
                .foregroundColor(.secondaryText)

            GameCard(
                teamName: game.team?.name ?? "Team",
                opponentName: "Opponent",
                teamScore: game.teamScore,
                opponentScore: Int(game.opponentScore),
                gameDate: Date(),
                result: game.result,
                focusPlayerStats: ""
            ) {
                viewModel.viewGameSummary(game)
            }
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Recent Activity:")
                .font(.headline)
                .foregroundColor(.secondaryText)

            ForEach(viewModel.recentActivities) { activity in
                HStack {
                    Image(systemName: activity.icon)
                }
                .padding(.spacingM)
                .background(Color.cardBackground)
                .cornerRadius(.cornerRadiusSmall)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with test data using helper
        let context = CoreDataStack.createInMemoryStack().mainContext
        _ = TestDataHelper.createCompleteTestSetup(context: context)

        return HomeView()
            .environment(\.managedObjectContext, context)
    }
}
