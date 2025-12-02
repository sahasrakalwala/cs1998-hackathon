//
//  AddTaskView.swift
//  cs1998-hackathon
//
//  Created by Anderson Ramirez on 12/2/25.
//

import SwiftUI

struct AddTaskView: View {
    @State private var title = ""
    @State private var date = Date()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            TextField("Title", text: $title)
            DatePicker("Due Date", selection: $date, displayedComponents: .date)
        }.navigationTitle("Add Task").toolbar {
            Button("Save") {
                dismiss()
            }
        }
    }
}
