//
//  ContactsChangeNotifierTests.swift
//  ContactsChangeNotifierTests
//
//  Created by Yonat Sharon on 15/07/2022.
//

import Contacts
import ContactsChangeNotifier
import XCTest

class ContactsChangeNotifierTests: XCTestCase {
    let contactStore = CNContactStore()

    func testInternalUpdate() async throws {
        _ = NotificationCenter.default.addObserver(
            forName: ContactsChangeNotifier.didChangeNotification,
            object: nil,
            queue: .main
        ) { notification in
            XCTFail("Got changes when they were internal: \(notification.contactsChangeEvents ?? [])")
        }
        try await contactStore.requestAccess(for: .contacts)
        let notifier = try ContactsChangeNotifier(store: contactStore, fetchRequest: .fetchRequest(additionalContactKeyDescriptors: [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
        ]))

        let changeExpectation = expectation(forNotification: .CNContactStoreDidChange, object: nil)
        changeExpectation.assertForOverFulfill = false

        let newContact = CNMutableContact()
        newContact.givenName = "New"
        let saveRequest = CNSaveRequest()
        saveRequest.add(newContact, toContainerWithIdentifier: contactStore.defaultContainerIdentifier())
        try contactStore.execute(saveRequest)

        wait(for: [changeExpectation], timeout: 1)

        // allow time for ContactsChangeNotifier.didChangeNotification to be sent:
        try await Task.sleep(nanoseconds: .second / 4)

        let changes = try notifier.changeHistory()
        XCTAssertEqual(changes.allObjects.count, 0, "internal change saved, and skipped by notifier")

        let cleanupRequest = CNSaveRequest()
        cleanupRequest.delete(newContact)
        try contactStore.execute(cleanupRequest)
    }
}

extension UInt64 {
    static let second: Self = 1_000_000_000
}
