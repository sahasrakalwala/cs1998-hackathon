//
//  DashboardView.swift
//  cs1998-hackathon
//
//  Created by Anderson Ramirez on 12/2/25.
//

import SwiftUI

struct DashboardView: View {
    let sampleRecommendations = [
        "Study INFO 2950 – 2 hours",
        "Read ECON Ch. 4 – 1 hour",
        "Prepare SPAN essay – 1.5 hours",
        "Review CS notes – 1 hour"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("Today's Recommendations")
                        .font(.title2)
                        .bold()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(sampleRecommendations, id: \.self) { rec in
                            Text(rec)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                NavigationLink("Tasks") {
                    TaskListView()
                }
            }
        }
    }
}
