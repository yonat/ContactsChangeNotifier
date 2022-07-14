//
//  CNContactStore+ChangeHistory.m
//  CallAbout
//
//  Created by Yonat Sharon on 06/07/2022.
//

#import "CNContactStore+ChangeHistory.h"

@implementation CNContactStore (ChangeHistory)

- (CNFetchResult<NSEnumerator<CNChangeHistoryEvent *> *> *)swiftEnumeratorForChangeHistoryFetchRequest:(CNChangeHistoryFetchRequest *)request
                                                                                                 error:(NSError * _Nullable *)error
{
    return [self enumeratorForChangeHistoryFetchRequest:request error:error];
}

@end
