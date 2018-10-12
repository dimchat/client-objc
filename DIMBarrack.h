//
//  DIMBarrack.h
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCore.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Entity pool to manage User/Contace/Group instances
 *
 *      1st, get instance here to avoid create same instance,
 *      2nd, if their history was updated, we can notice them here immediately
 */
@interface DIMBarrack : NSObject <MKMEntityDelegate, MKMProfileDelegate>

+ (instancetype)sharedInstance;

// user
- (DIMUser *)userForID:(const MKMID *)ID; // if not found, create new one
- (void)setUser:(DIMUser *)user; // create moments at the same time
- (void)removeUser:(const DIMUser *)user; // remove moments too

// contact
- (DIMContact *)contactForID:(const MKMID *)ID; // if not found, create new one
- (void)setContact:(DIMContact *)contact; // create moments at the same time
- (void)removeContact:(const DIMContact *)contact; // remove moments too

// group
- (DIMGroup *)groupForID:(const MKMID *)ID; // if not found, create new one
- (void)setGroup:(DIMGroup *)group;
- (void)removeGroup:(const DIMGroup *)group;

// moments, only set by user/contact
- (DIMMoments *)momentsForID:(const MKMID *)ID; // won't create instance here
//- (void)setMoments:(DIMMoments *)moments;
//- (void)removeMoments:(const DIMMoments *)moments;

@end

NS_ASSUME_NONNULL_END
