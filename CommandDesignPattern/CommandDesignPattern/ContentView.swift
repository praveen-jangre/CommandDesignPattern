//
//  ContentView.swift
//  CommandDesignPattern
//
//  Created by Praveen Jangre on 27/06/2025.
//

import SwiftUI
import SwiftData

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool = false
    var dueDate: Date
}

class TaskStore: ObservableObject {
    @Published var tasks: [Task] = []
    private var undoStack: [Commands] = []
    private var redoStack: [Commands] = []
    
    func execute(_ command: Commands) {
        command.execute()
        undoStack.append(command)
        redoStack.removeAll()
        
        print("Executed: \(type(of: command))")
    }
    
    
    func undo() {
        guard let command = undoStack.popLast() else { return  }
        
        command.undo()
        redoStack.append(command)
    }
    
    func redo() {
        guard let command = redoStack.popLast() else { return  }
        command.execute()
        undoStack.append(command)
    }
    
    
    func addTask(title: String) {
        tasks.append(Task(title: title, dueDate: Date()))
    }
    
    func toggleTaskCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    func deleteTask(task: Task) {
        tasks.removeAll(where: { $0.id == task.id })
    }
    
    func postponeTask(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id}){
            tasks[index].dueDate = Calendar.current.date(byAdding: .day, value: 1, to: tasks[index].dueDate)!
        }
    }
}



struct ContentView: View {
    
    @StateObject private var taskStore = TaskStore()
    @State private var newTaskTitle = ""
    @State private var showPostponeAlert = false
    

    var body: some View {
        NavigationView {
            List {
                ForEach(taskStore.tasks) { task in
                    HStack {
                        Text(task.title)
                        Spacer()
                        Button(action: {
                            taskStore.execute(ToggleTaskCompletion(taskStore: taskStore, task: task))
                        }){
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        }
                        
                        Button(action: {
                            taskStore.execute(PostponeTaskCommand(taskStore: taskStore, task: task))
                            showPostponeAlert = true
                        }) {
                            Image(systemName: "clock.arrow.circlepath")
                        }
                    }
                }
                .onDelete { indexSet in
                    let tasksToDelete = indexSet.map { taskStore.tasks[$0] }
                    tasksToDelete.forEach { taskStore.execute(DeleteTaskCommand(taskStore: taskStore, task: $0)) }
                }
            }
            .buttonStyle(.borderless)
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        TextField("New Task", text: $newTaskTitle)
                        Button("Add") {
                            taskStore.execute(AddTaskCommand(taskStore: taskStore, title: newTaskTitle))
                            newTaskTitle = ""
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button(action: {taskStore.undo()}){
                            Image(systemName: "arrow.uturn.backward")
                        }
                        Button(action: {taskStore.redo()}){
                            Image(systemName: "arrow.uturn.forward")
                        }
                    }
                }
            }
            .alert("Task postponed", isPresented: $showPostponeAlert) {
                Button("OK", role: .cancel){}
            } message: {
                Text(" Task due date increased by 1 day")
            }
        }
        
        
    }
}

#Preview {
    ContentView()

}
