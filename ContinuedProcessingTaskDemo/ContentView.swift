//
//  ContentView.swift
//  ContinuedProcessingTaskDemo
//
//  Created by Ahnaf Mahmud on 07/08/2025.
//

import SwiftUI
import BackgroundTasks

struct ContentView: View {
    
    /// The identifier for the background continued processing task.
    /// This should match the identifier specified in the Info.plist under `BGTaskSchedulerPermittedIdentifiers`.
    private let taskId = "\(Bundle.main.bundleIdentifier!).background"
    
    /// The title that is shown in the live activity for the background continued processing task.
    private let title = "Background Task"
    
    init() {
        register()
    }
    
    var body: some View {
        VStack {
            Button("Run Task") {
                runTask()
            }
            .buttonStyle(.glassProminent)
        }
        .padding()
    }
    
    /// Registers the background continued processing task with the system.
    private func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskId, using: nil) { task in
            guard let task = task as? BGContinuedProcessingTask else { return }
            
            var wasExpired = false
            
            task.expirationHandler = {
                wasExpired = true
            }
            
            task.progress.totalUnitCount = 100
            task.progress.completedUnitCount = 0
            
            while (task.progress.completedUnitCount < task.progress.totalUnitCount) && !wasExpired && !task.progress.isFinished {
                sleep(1)
                task.progress.completedUnitCount += 1
                task.updateTitle(title, subtitle: "\(task.progress.completedUnitCount)% complete")
            }
        }
    }
    
    private func runTask() {
        let request = BGContinuedProcessingTaskRequest(
            identifier: taskId,
            title: title,
            subtitle: "Running..."
        )
        request.strategy = .queue
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print(error)
        }
    }
}

#Preview {
    ContentView()
}
