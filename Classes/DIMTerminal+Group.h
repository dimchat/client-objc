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

- (nullable DIMGroup *)createGroupWithSeed:(NSString *)seed
                                   members:(NSArray<DIMID *> *)list
                                   profile:(nullable NSDictionary *)dict;

- (BOOL)updateGroupWithID:(DIMID *)ID
                  members:(NSArray<DIMID *> *)list
                  profile:(nullable DIMProfile *)profile;

@end

@interface DIMTerminal (GroupHistory)

// group history command
- (BOOL)checkGroupCommand:(DIMGroupCommand *)cmd commander:(DIMID *)sender;

@end

NS_ASSUME_NONNULL_END
