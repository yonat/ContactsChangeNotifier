//
//  ContentView.swift
//  ContactsChangeNotifierDemo
//
//  Created by Yonat Sharon on 14/07/2022.
//

import ContactsChangeNotifier
import SwiftUI

struct ContentView: View {
    @State private var changes: [String] = []
    @State private var changeDate: Date?

    let contactsChangeNotifier = try? ContactsChangeNotifier(
        store: CNContactStore(),
        fetchRequest: .fetchRequest(additionalContactKeyDescriptors: [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
        ])
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Changes:")
                .bold()
            if changes.isEmpty {
                Text("No changes")
                Text("Change some contacts outside the app, and then they will show up here.")
            } else {
                ForEach(changes.indices, id: \.self) { index in
                    Text(LocalizedStringKey(changes[index]))
                }
            }
            if let changeDate = changeDate {
                Text("Updated: \(changeDate)")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: ContactsChangeNotifier.didChangeNotification)) { notification in
            guard let events = notification.contactsChangeEvents else { return }
            changeDate = Date()
            changes = events.map { $0.changeDescription }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
