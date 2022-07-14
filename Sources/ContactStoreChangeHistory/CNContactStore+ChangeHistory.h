//
//  CNContactStore+ChangeHistory.h
//  CallAbout
//
//  Created by Yonat Sharon on 06/07/2022.
//

#import <Contacts/Contacts.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNContactStore (ChangeHistory)

/// Access `enumeratorForContactFetchRequest:error:` from Swift - Enumerates a change history fetch request.
/// @param request A description of the events to fetch.
/// @param error If the fetch fails, contains an `NSError` object with more information.
/// @return An enumerator of the events matching the result, or nil if there was an error.
- (CNFetchResult<NSEnumerator<CNChangeHistoryEvent *> *> *)swiftEnumeratorForChangeHistoryFetchRequest:(CNChangeHistoryFetchRequest *)request
                                                                                                 error:(NSError * _Nullable *)error;
@end

NS_ASSUME_NONNULL_END
