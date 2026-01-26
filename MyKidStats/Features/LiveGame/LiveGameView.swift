import SwiftUI

struct LiveGameView: View {
    @StateObject private var viewModel: LiveGameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEndGameAlert = false

    init(game: Game, focusPlayer: Player) {
        _viewModel = StateObject(
            wrappedValue: LiveGameViewModel(game: game, focusPlayer: focusPlayer)
        )
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: .spacingXL) {
                    opponentScoringSection
                    focusPlayerSection
                    teamScoringSection
                    Color.clear.frame(height: 80)
                }
                .padding(.spacingL)
            }
            .background(Color.appBackground)

            if viewModel.canUndo {
                undoButton
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationTitle("\(viewModel.game.team?.name ?? "Team") vs \(viewModel.game.opponentName)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("End Game", role: .destructive) {
                    showEndGameAlert = true
                }
            }
        }
        .alert("End Game?", isPresented: $showEndGameAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End Game", role: .destructive) {
                viewModel.endGame()
                dismiss()
            }
        } message: {
            Text("Mark this game as complete?")
        }
    }

    private var opponentScoringSection: some View {
        VStack(spacing: .spacingM) {
            Text("Opponent Scoring:")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Text("\(viewModel.game.team?.name ?? "Team") \(viewModel.teamScore)")
                    .font(.scoreLarge)
                Text("•")
                    .foregroundColor(.secondaryText)
                Text("\(viewModel.game.opponentName) \(viewModel.opponentScore)")
                    .font(.scoreLarge)
            }

            HStack(spacing: .spacingM) {
                TeamScoreButton(points: 1) {
                    viewModel.recordOpponentScore(1)
                }
                TeamScoreButton(points: 2) {
                    viewModel.recordOpponentScore(2)
                }
                TeamScoreButton(points: 3) {
                    viewModel.recordOpponentScore(3)
                }
            }
        }
        .padding()
        .background(Color.fill)
        .cornerRadius(.cornerRadiusCard)
    }

    private var focusPlayerSection: some View {
        VStack(spacing: .spacingL) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                Text(viewModel.focusPlayer.child?.name ?? "")
                    .font(.playerName)
                Spacer()
                Text("#\(viewModel.focusPlayer.jerseyNumber ?? "")")
                    .font(.title3)
                    .foregroundColor(.secondaryText)
            }

            VStack(spacing: .spacingM) {
                HStack(spacing: .spacingM) {
                    StatButton(type: .twoPointMade, count: twoMadeCount) {
                        viewModel.recordFocusPlayerStat(.twoPointMade)
                    }
                    StatButton(type: .twoPointMiss, count: twoMissCount) {
                        viewModel.recordFocusPlayerStat(.twoPointMiss)
                    }
                    StatButton(type: .threePointMade, count: viewModel.currentStats.threeMade) {
                        viewModel.recordFocusPlayerStat(.threePointMade)
                    }
                    StatButton(type: .threePointMiss, count: threeMissCount) {
                        viewModel.recordFocusPlayerStat(.threePointMiss)
                    }
                }

                HStack(spacing: .spacingM) {
                    StatButton(type: .freeThrowMade, count: viewModel.currentStats.ftMade) {
                        viewModel.recordFocusPlayerStat(.freeThrowMade)
                    }
                    StatButton(type: .freeThrowMiss, count: ftMissCount) {
                        viewModel.recordFocusPlayerStat(.freeThrowMiss)
                    }
                    Spacer().frame(width: .buttonSizeFocus)
                    Spacer().frame(width: .buttonSizeFocus)
                }
            }

            VStack(spacing: .spacingM) {
                HStack(spacing: .spacingM) {
                    StatButton(type: .rebound, count: viewModel.currentStats.rebounds) {
                        viewModel.recordFocusPlayerStat(.rebound)
                    }
                    StatButton(type: .assist, count: viewModel.currentStats.assists) {
                        viewModel.recordFocusPlayerStat(.assist)
                    }
                    StatButton(type: .steal, count: viewModel.currentStats.steals) {
                        viewModel.recordFocusPlayerStat(.steal)
                    }
                    StatButton(type: .block, count: viewModel.currentStats.blocks) {
                        viewModel.recordFocusPlayerStat(.block)
                    }
                }

                HStack(spacing: .spacingM) {
                    StatButton(type: .turnover, count: viewModel.currentStats.turnovers) {
                        viewModel.recordFocusPlayerStat(.turnover)
                    }
                    StatButton(type: .foul, count: viewModel.currentStats.fouls) {
                        viewModel.recordFocusPlayerStat(.foul)
                    }
                    Spacer().frame(width: .buttonSizeFocus)
                    Spacer().frame(width: .buttonSizeFocus)
                }
            }

            Text(summaryText)
                .font(.summaryText.bold())
                .foregroundColor(.secondaryText)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(.cornerRadiusCard)
    }

    private var twoMadeCount: Int {
        viewModel.currentStats.fgMade - viewModel.currentStats.threeMade
    }

    private var twoMissCount: Int {
        let twoAttempted = viewModel.currentStats.fgAttempted - viewModel.currentStats.threeAttempted
        let twoMade = viewModel.currentStats.fgMade - viewModel.currentStats.threeMade
        return twoAttempted - twoMade
    }

    private var threeMissCount: Int {
        viewModel.currentStats.threeAttempted - viewModel.currentStats.threeMade
    }

    private var ftMissCount: Int {
        viewModel.currentStats.ftAttempted - viewModel.currentStats.ftMade
    }

    private var summaryText: String {
        let stats = viewModel.currentStats
        return "\(stats.points) PTS • \(stats.fgMade)/\(stats.fgAttempted) FG (\(Int(stats.fgPercentage))%) • \(stats.ftMade)/\(stats.ftAttempted) FT"
    }

    private var teamScoringSection: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text("Team Scoring")
                .font(.headline)

            ForEach(viewModel.teamPlayers.filter { $0.id != viewModel.focusPlayer.id }, id: \.id) { player in
                TeamScoringRow(
                    jerseyNumber: player.jerseyNumber ?? "?",
                    playerName: player.child?.name ?? "",
                    currentScore: viewModel.teamScores[player.id] ?? 0
                ) { points in
                    viewModel.recordTeamPlayerScore(player.id, points: points)
                }
            }
        }
    }

    private var undoButton: some View {
        Button(action: viewModel.undoLastAction) {
            HStack {
                Image(systemName: "arrow.uturn.backward")
                Text("Undo")
            }
            .font(.body.bold())
            .foregroundColor(.white)
            .padding(.horizontal, .spacingL)
            .padding(.vertical, .spacingM)
            .background(Color.red)
            .cornerRadius(.buttonSizeUndo / 2)
            .shadow(radius: 4)
        }
        .padding(.spacingL)
    }
}

struct LiveGameView_Previews: PreviewProvider {
    static var previews: some View {
        // Minimal preview using placeholder objects if available
        Text("LiveGameView Preview")
    }
}
