//
//  Commands.swift
//  CommandDesignPattern
//
//  Created by Praveen Jangre on 28/06/2025.
//

import Foundation


protocol Commands {
    func execute()
    func undo()
    
}

class AddTaskCommand: Commands {
    func execute() {
        taskStore.tasks.append(task)
    }
    
    func undo() {
        taskStore.tasks.removeAll(where: { $0.id == task.id })
    }
    
    private let taskStore: TaskStore
    private let task: Task
    
    init(taskStore: TaskStore, title: String) {
        self.taskStore = taskStore
        self.task = Task(title: title, dueDate: Date())
    }
}


class ToggleTaskCompletion: Commands {
    func execute() {
        if let index = taskStore.tasks.firstIndex(where: {$0.id == task.id }){
            taskStore.tasks[index].isCompleted.toggle()
        }
    }
    
    func undo() {
        if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id}){
            taskStore.tasks[index].isCompleted.toggle()
        }
    }
    
    private let taskStore: TaskStore
    private let task: Task
    
    init(taskStore: TaskStore, task: Task) {
        self.taskStore = taskStore
        self.task = task
    }
    
}

class DeleteTaskCommand: Commands {
    private let taskStore: TaskStore
    private let task: Task
    private var index: Int?
    
    init(taskStore: TaskStore, task: Task) {
        self.taskStore = taskStore
        self.task = task
    }
    
    func execute() {
        if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }){
            self.index = index
            taskStore.tasks.remove(at: index)
            
        }
    }
    
    func undo() {
        if let index = index {
            taskStore.tasks.insert(task, at: index)
        }
    }
}

class PostponeTaskCommand: Commands {
    private let taskStore: TaskStore
    private let task: Task
    private var oldDate: Date?
    
    init(taskStore: TaskStore, task: Task) {
        self.taskStore = taskStore
        self.task = task
    }
    
    func execute() {
        if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }){
            oldDate = taskStore.tasks[index].dueDate
            taskStore.tasks[index].dueDate = Calendar.current.date(byAdding: .day, value: 1, to: taskStore.tasks[index].dueDate)!
        }
    }
    
    func undo() {
        if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }),
            let oldDate = oldDate {
                taskStore.tasks[index].dueDate = oldDate
            }
    }
    
    
}
