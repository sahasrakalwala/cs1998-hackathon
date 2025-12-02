//
//  TaskListView.swift
//  cs1998-hackathon
//
//  Created by Anderson Ramirez on 12/2/25.
//

import SwiftUI

struct TaskListView: View {
    
    let sampleTasks = [
        "Essay Draft",
        "INFO HW",
        "CS Project"
    ]
    
    var body: some View {
        List(sampleTasks, id:\.self) {
            task in NavigationLink(task) {
                TaskDetailView(task: task)
            }
        }.navigationTitle("Tasks").toolbar {
            NavigationLink("Add") {
                AddTaskView()
            }
        }
    }
}
