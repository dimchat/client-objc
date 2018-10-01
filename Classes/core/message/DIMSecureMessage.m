//
//  DIMSecureMessage.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMEnvelope.h"
#import "DIMInstantMessage.h"

#import "DIMSecureMessage.h"

static NSDate *now() {
    return [[NSDate alloc] init];
}

//static NSNumber *time_number(const NSDate *time) {
//    if (!time) {
//        time = now();
//    }
//    NSTimeInterval ti = [time timeIntervalSince1970];
//    return [NSNumber numberWithDouble:ti];
//}

static NSDate *number_time(const NSNumber *number) {
    NSTimeInterval ti = [number doubleValue];
    if (ti == 0) {
        return now();
    }
    return [[NSDate alloc] initWithTimeIntervalSince1970:ti];
}

@interface DIMSecureMessage ()

@property (strong, nonatomic) const DIMEnvelope *envelope;
@property (strong, nonatomic) const NSData *content;

@property (strong, nonatomic) const NSData *secretKey;

@end

@implementation DIMSecureMessage

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    NSData *content = nil;
    DIMEnvelope *env = nil;
    NSData *key = nil;
    self = [self initWithContent:content
                        envelope:env
                       secretKey:key];
    return self;
}

- (instancetype)initWithContent:(const NSData *)content
                       envelope:(const DIMEnvelope *)env
                      secretKey:(const NSData *)key {
    NSAssert(env, @"envelope cannot be empty");
    NSMutableDictionary *mDict;
    mDict = [[NSMutableDictionary alloc] initWithDictionary:(id)env];
    // content
    NSAssert(content, @"content cannot be empty");
    [mDict setObject:[content base64Encode] forKey:@"content"];
    // secret key
    NSAssert(key, @"key cannot be empty");
    [mDict setObject:[key base64Encode] forKey:@"secretKey"];
    
    if (self = [super initWithDictionary:mDict]) {
        self.envelope = env;
        self.content = content;
        self.secretKey = key;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // sender
        id from = [dict objectForKey:@"sender"];
        if (from) {
            from = [MKMID IDWithID:from];
        }
        // receiver
        id to = [dict objectForKey:@"receiver"];
        if (to) {
            to = [MKMID IDWithID:to];
        }
        // time
        id time = [dict objectForKey:@"time"];
        if (time) {
            time = number_time(time);
        }
        
        DIMEnvelope *env;
        env = [[DIMEnvelope alloc] initWithSender:from
                                         receiver:to
                                             time:time];
        self.envelope = env;
        
        // content
        NSString *content = [dict objectForKey:@"content"];
        NSAssert(content, @"content cannot be empty");
        self.content = [content base64Decode];
        
        // secret key
        NSString *secret = [dict objectForKey:@"key"];
        self.secretKey = [secret base64Decode];
    }
    
    return self;
}

@end
