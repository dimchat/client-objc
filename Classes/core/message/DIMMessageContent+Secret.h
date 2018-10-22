//
//  DIMMessageContent+Secret.h
//  DIM
//
//  Created by Albert Moky on 2018/10/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMCertifiedMessage;

@interface DIMMessageContent (TopSecret)

// Top-Secret message forwarded by a proxy (Service Provider)
@property (readonly, nonatomic) DIMCertifiedMessage *secretMessage;

/**
 *  Top-Secret message: {
 *      type: 0xFF,
 *      sn: 123,
 *
 *      forward: {...}  // certified secure message
 *  }
 */
- (instancetype)initWithSecretMessage:(const DIMCertifiedMessage *)cMsg;

@end

NS_ASSUME_NONNULL_END
