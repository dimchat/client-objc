//
//  DIMTerminal+Request.h
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMTerminal.h"

NS_ASSUME_NONNULL_BEGIN

extern const NSString *kNotificationName_MessageSent;
extern const NSString *kNotificationName_SendMessageFailed;

@interface DIMTerminal (Request)

- (void)sendContent:(DIMMessageContent *)content to:(const DIMID *)receiver;
- (void)sendMessage:(DIMInstantMessage *)msg;

// pack and send command to station
- (void)sendCommand:(DIMCommand *)cmd;

#pragma mark -

- (void)login:(DIMUser *)user;

- (void)postProfile:(DIMProfile *)profile meta:(nullable const DIMMeta *)meta;

- (void)queryMetaForID:(const DIMID *)ID;
- (void)queryProfileForID:(const DIMID *)ID;

- (void)queryOnlineUsers;
- (void)searchUsersWithKeywords:(const NSString *)keywords;

@end

NS_ASSUME_NONNULL_END
