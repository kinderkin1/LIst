//
//  ListApp.swift
//  List
//
//  Created by Kinder on 25/12/2021.
//

import SwiftUI

@main
struct ListApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
