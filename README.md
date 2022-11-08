# ContactsChangeNotifier

Which contacts changed outside your iOS app? Better `CNContactStoreDidChange` notification: Get real changes, without the noise.

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ContactsChangeNotifier.svg)](https://img.shields.io/cocoapods/v/ContactsChangeNotifier.svg)
[![Platform](https://img.shields.io/cocoapods/p/ContactsChangeNotifier.svg?style=flat)](http://cocoapods.org/pods/ContactsChangeNotifier)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)


## Why Oh Why

Sadly, the Contacts changes API is a mess:

- The `CNContactStoreDidChange` notification is received for changes your own code did, not just outside your app. 🤷
- It contains undocumented `userInfo` fields. 🙈
- To get the actual changes, you need to use an Objective-C API that is not even callable from Swift. 😱
- That API is easy to get wrong, and requires maintaining opaque state, or receiving the complete changes history. 🧨

It’s the API that time forgot. 🧟‍♂️

## ContactsChangeNotifier Features

* Only get notified for changes outside your app. 🎯
* Get the list of changes included in the notification. 🎁
* Only get changes since last notification, not the full all-time history. ✨
* No Objective-C required. 💥

## Usage

1. Get the user's Contacts access permission (see [docs](https://developer.apple.com/documentation/contacts/requesting_authorization_to_access_contacts)).
2. Keep a `ContactsChangeNotifier` instance -
   it will observe all Contacts changes but post only those that from outside your app.   
3. Observe `ContactsChangeNotifier.didChangeNotification` notification.
4. See change events in the notification's `contactsChangeEvents`.

```swift
// 2. Keep a ContactsChangeNotifier instance
let contactsChangeNotifier = try! ContactsChangeNotifier(
    store: myCNContactStore,
    fetchRequest: .fetchRequest(additionalContactKeyDescriptors: myCNKeyDescriptors)
)

// 3. Observe ContactsChangeNotifier.didChangeNotification notification
let observation = NotificationCenter.default.addObserver(
    forName: ContactsChangeNotifier.didChangeNotification,
    object: nil,
    queue: nil
) { notification in
    // 4. See change events in the notification's contactsChangeEvents
    for event in notification.contactsChangeEvents ?? [] {
        switch event {
        case let addEvent as CNChangeHistoryAddContactEvent:
            print(addEvent.contact)
        case let updateEvent as CNChangeHistoryUpdateContactEvent:
            print(updateEvent.contact)
        case let deleteEvent as CNChangeHistoryDeleteContactEvent:
            print(deleteEvent.contactIdentifier)
        default:
            // group event
            break
        }
    }
}
```

## Installation

### CocoaPods:

```ruby
pod 'ContactsChangeNotifier'
```

### Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yonat/ContactsChangeNotifier", from: "1.0.3")
]
```

[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE.txt
