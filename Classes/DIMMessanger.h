//
//  DIMMessanger.h
//  DIMClient
//
//  Created by Albert Moky on 2019/8/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMMessanger : DIMTransceiver

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
