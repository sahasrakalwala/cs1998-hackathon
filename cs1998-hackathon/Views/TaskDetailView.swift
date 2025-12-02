//
//  TaskDetailView.swift
//  cs1998-hackathon
//
//  Created by Anderson Ramirez on 12/2/25.
//

import SwiftUI

struct TaskDetailView: View {
    let task: String
    
    var body: some View {
        VStack {
            Text(task).font(.largeTitle).padding()
            Text("Task details screen placeholder").foregroundColor(.secondary)
            
            Spacer()
        }.navigationTitle("Task Details").padding()
    }
}
