//
//  HelpView.swift
//  MyKidStats
//
//  Created by Copilot on 2/1/26.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedTopic: HelpTopic?
    
    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty {
                    categorizedTopics
                } else {
                    searchResults
                }
            }
            .navigationTitle("Help & User Guide")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search help topics")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedTopic) { topic in
                HelpTopicView(topic: topic)
            }
        }
    }
    
    private var categorizedTopics: some View {
        ForEach(HelpCategory.allCases) { category in
            Section(header: categoryHeader(category)) {
                ForEach(category.topics) { topic in
                    topicRow(topic)
                }
            }
        }
    }
    
    private var searchResults: some View {
        let filteredTopics = HelpTopic.allCases.filter { topic in
            topic.rawValue.localizedCaseInsensitiveContains(searchText) ||
            topic.content.sections.contains { section in
                section.title.localizedCaseInsensitiveContains(searchText) ||
                section.body.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return Group {
            if filteredTopics.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                ForEach(filteredTopics) { topic in
                    topicRow(topic)
                }
            }
        }
    }
    
    private func categoryHeader(_ category: HelpCategory) -> some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundColor(.accentColor)
            Text(category.rawValue)
        }
    }
    
    private func topicRow(_ topic: HelpTopic) -> some View {
        Button(action: { selectedTopic = topic }) {
            HStack {
                Image(systemName: topic.icon)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(topic.rawValue)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    if let firstSection = topic.content.sections.first {
                        Text(String(firstSection.body.prefix(60)) + "...")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HelpView()
}
