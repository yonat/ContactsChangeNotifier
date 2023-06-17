//
//  CNContactStore+ChangeHistory.h
//  CallAbout
//
//  Created by Yonat Sharon on 06/07/2022.
//

#import <Contacts/Contacts.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNContactStore (ChangeHistory)

/// Access `currentHistoryToken` from Swift. Avoid case `currentHistoryToken` is nil in Swift
@property (strong, atomic, readonly) NSData *lastHistoryToken API_AVAILABLE(ios(13.0), macos(10.15));

/// Access `enumeratorForContactFetchRequest:error:` from Swift - Enumerates a change history fetch request.
/// @param request A description of the events to fetch.
/// @param error If the fetch fails, contains an `NSError` object with more information.
/// @return An enumerator of the events matching the result, or nil if there was an error.
- (CNFetchResult<NSEnumerator<CNChangeHistoryEvent *> *> *)swiftEnumeratorForChangeHistoryFetchRequest:(CNChangeHistoryFetchRequest *)request
                                                                                                 error:(NSError * _Nullable *)error API_AVAILABLE(ios(13.0), macos(10.15));
@end

NS_ASSUME_NONNULL_END
