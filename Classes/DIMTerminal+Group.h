//
//  DIMTerminal+Group.h
//  DIMClient
//
//  Created by Albert Moky on 2019/3/9.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMClient/DIMClient.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMTerminal (GroupManage)

- (nullable DIMGroup *)createGroupWithSeed:(const NSString *)seed
                                   members:(const NSArray<const DIMID *> *)list
                                   profile:(nullable NSDictionary *)dict;

- (BOOL)updateGroupWithID:(const DIMID *)ID
                  members:(const NSArray<const DIMID *> *)list
                  profile:(nullable DIMProfile *)profile;

@end

@interface DIMTerminal (GroupHistory)

// group history command
- (BOOL)checkGroupCommand:(DIMCommand *)cmd commander:(const DIMID *)sender;

@end

NS_ASSUME_NONNULL_END
