//
//  LocalDatabaseManager.h
//  TimeFriend
//
//  Created by 陈均卓 on 2019/5/18.
//  Copyright © 2019 John Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocalDatabaseManager : NSObject

+(instancetype)sharedInstance;

-(void)createTables;

-(BOOL)insertConversation:(DIMID *)conversationID;
-(BOOL)updateConversation:(DIMID *)conversationID name:(NSString *)name image:(NSString *)imagePath lastMessage:(DIMInstantMessage *)msg;
-(NSMutableArray<DIMID *> *)loadAllConversations;
-(BOOL)clearConversation:(DIMID *)conversationID;
-(BOOL)deleteConversation:(DIMID *)conversationID;
    
-(BOOL)addMessage:(DIMInstantMessage *)msg toConversation:(DIMID *)conversationID;
-(NSMutableArray<DIMInstantMessage *> *)loadMessagesInConversation:(DIMID *)conversationID limit:(NSInteger)limit offset:(NSInteger)offset;

@end

NS_ASSUME_NONNULL_END
