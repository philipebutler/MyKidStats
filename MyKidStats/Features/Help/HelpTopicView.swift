//
//  HelpTopicView.swift
//  MyKidStats
//
//  Created by Copilot on 2/1/26.
//

import SwiftUI

struct HelpTopicView: View {
    let topic: HelpTopic
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: .spacingXL) {
                    ForEach(topic.content.sections) { section in
                        sectionView(section)
                    }
                }
                .padding()
            }
            .navigationTitle(topic.content.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func sectionView(_ section: HelpSection) -> some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            Text(section.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(section.body)
                .font(.body)
                .foregroundColor(.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            
            // Placeholder for screenshots
            if let imageName = section.imageName {
                screenshotPlaceholder(imageName)
            }
        }
    }
    
    private func screenshotPlaceholder(_ imageName: String) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.2))
            .frame(height: 200)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text(imageName)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                    Text("Screenshot placeholder")
                        .font(.caption2)
                        .foregroundColor(.secondaryText)
                }
            )
            .padding(.vertical, 8)
    }
}

#Preview {
    HelpTopicView(topic: .quickStart)
}
