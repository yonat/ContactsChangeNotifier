//
//  Contacts+Extensions.swift
//  ContactsChangeNotifierDemo
//
//  Created by Yonat Sharon on 14/07/2022.
//

import Contacts

extension CNContact {
    var fullName: String {
        CNContactFormatter.string(from: self, style: .fullName) ?? "Unknown"
    }
}

extension CNChangeHistoryEvent {
    var changeDescription: String {
        switch self {
        case let addEvent as CNChangeHistoryAddContactEvent:
            return "Add **\(addEvent.contact.fullName)** `\(addEvent.contact.identifier)`"
        case let updateEvent as CNChangeHistoryUpdateContactEvent:
            return "Update **\(updateEvent.contact.fullName)** `\(updateEvent.contact.identifier)`"
        case let deleteEvent as CNChangeHistoryDeleteContactEvent:
            return "Delete `\(deleteEvent.contactIdentifier)`"
        case _ as CNChangeHistoryDropEverythingEvent:
            return "Initial update"
        default:
            return "Group event"
        }
    }
}
