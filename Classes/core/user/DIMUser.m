//
//  DIMUser.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DIMInstantMessage.h"
#import "DIMSecureMessage.h"
#import "DIMCertifiedMessage.h"
#import "DIMEnvelope.h"
#import "DIMMessageContent.h"

#import "DIMUser.h"

@implementation DIMUser

+ (instancetype)userWithID:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Main, @"address error");
    MKMConsensus *cons = [MKMConsensus sharedInstance];
    MKMEntityManager *eman = [MKMEntityManager sharedInstance];
    MKMMeta *meta = [eman metaWithID:ID];
    MKMHistory *history = [eman historyWithID:ID];
    DIMUser *user = [[DIMUser alloc] initWithID:ID meta:meta];
    if (user) {
        user.historyDelegate = cons;
        NSUInteger count = [user runHistory:history];
        NSAssert(count == history.count, @"history error");
    }
    return user;
}

- (DIMInstantMessage *)decryptMessage:(const DIMSecureMessage *)msg {
    DIMEnvelope *env = msg.envelope;
    NSAssert([env.receiver isEqual:_ID], @"recipient error");
    
    // 1. use the user's private key to decrypt the symmetric key
    NSData *PW = msg.secretKey;
    NSAssert(PW, @"secret key cannot be empty");
    PW = [self decrypt:PW];
    
    // 2. use the symmetric key to decrypt the content
    MKMSymmetricKey *scKey;
    scKey = [[MKMSymmetricKey alloc] initWithJSONString:[PW UTF8String]];
    NSData *CT = [scKey decrypt:msg.content];
    
    // 3. JsON
    NSString *json = [CT UTF8String];
    DIMMessageContent *content;
    content = [[DIMMessageContent alloc] initWithJSONString:json];
    
    // 4. create instant message
    return [[DIMInstantMessage alloc] initWithContent:content
                                             envelope:env];
}

- (DIMCertifiedMessage *)signMessage:(const DIMSecureMessage *)msg {
    DIMEnvelope *env = msg.envelope;
    NSAssert([env.sender isEqual:_ID], @"sender error");
    
    NSData *content = msg.content;
    NSAssert(content, @"content cannot be empty");
    
    // 1. use the user's private key to sign the content
    NSData *CT = [self sign:content];
    
    // 2. create certified message
    DIMCertifiedMessage *cMsg = nil;
    if (env.receiver.address.network == MKMNetwork_Main) {
        // Personal Message
        NSData *key = msg.secretKey;
        NSAssert(key, @"secret key not found");
        cMsg = [[DIMCertifiedMessage alloc] initWithContent:content
                                                   envelope:env
                                                  secretKey:key
                                                  signature:CT];
    } else if (env.receiver.address.network == MKMNetwork_Group) {
        // Group Message
        NSDictionary *keys = msg.secretKeys;
        NSAssert(keys, @"secret keys not found");
        cMsg = [[DIMCertifiedMessage alloc] initWithContent:content
                                                   envelope:env
                                                 secretKeys:keys
                                                  signature:CT];
    }
    return cMsg;
}

#pragma mark - Decrypt/Sign functions for passphrase/signature

- (NSData *)decrypt:(const NSData *)ciphertext {
    MKMPrivateKey *SK = [self privateKey];
    return [SK decrypt:ciphertext];
}

- (NSData *)sign:(const NSData *)plaintext {
    MKMPrivateKey *SK = [self privateKey];
    return [SK sign:plaintext];
}

@end
