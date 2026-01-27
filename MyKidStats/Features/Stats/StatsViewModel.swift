//
//  StatsViewModel.swift
//  MyKidStats
//
//  Created by Copilot on 1/27/26.
//

import Foundation
import CoreData
import Combine

@MainActor
class StatsViewModel: ObservableObject {
    @Published var children: [Child] = []
    @Published var selectedChild: Child?
    @Published var careerStats: CareerStats?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let context: NSManagedObjectContext
    private let calculateCareerStatsUseCase: CalculateCareerStatsUseCase
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
        self.calculateCareerStatsUseCase = CalculateCareerStatsUseCase(context: context)
        loadChildren()
    }
    
    func loadChildren() {
        let request = NSFetchRequest<Child>(entityName: "Child")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            children = try context.fetch(request)
            if selectedChild == nil, let firstChild = children.first {
                selectedChild = firstChild
                loadCareerStats(for: firstChild)
            }
        } catch {
            errorMessage = "Failed to load children: \(error.localizedDescription)"
        }
    }
    
    func selectChild(_ child: Child) {
        selectedChild = child
        loadCareerStats(for: child)
    }
    
    private func loadCareerStats(for child: Child) {
        guard let childId = child.id else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                careerStats = try await calculateCareerStatsUseCase.execute(for: childId)
                isLoading = false
            } catch CareerError.noData {
                careerStats = nil
                errorMessage = "No games recorded yet"
                isLoading = false
            } catch {
                careerStats = nil
                errorMessage = "Failed to load stats: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}
