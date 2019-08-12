//
//  DIMTerminal.m
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DIMFacebook.h"
#import "DIMMessanger.h"

#import "DIMAmanuensis.h"

#import "DIMServer.h"
#import "DIMTerminal+Request.h"
#import "DIMTerminal+Response.h"
#import "DIMTerminal+Group.h"

#import "DIMTerminal.h"

@interface DIMTerminal ()

@end

@implementation DIMTerminal

- (instancetype)init {
    if (self = [super init]) {
        _users = [[NSMutableArray alloc] init];
        
        _currentStation = nil;
        _session = nil;
    }
    return self;
}

- (NSString *)language {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    return languages.firstObject;
}

#pragma mark - User(s)

- (NSArray<DIMLocalUser *> *)users {
    return [_users copy];
}

- (DIMLocalUser *)currentUser {
    return _currentStation.currentUser;
}

- (void)setCurrentUser:(DIMLocalUser *)user {
    _currentStation.currentUser = user;
    if (user && ![_users containsObject:user]) {
        // insert the user to the first
        [_users insertObject:user atIndex:0];
    }
    
    //Save current user
    [[NSUserDefaults standardUserDefaults] setObject:user.ID forKey:@"Current_User_ID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addUser:(DIMLocalUser *)user {
    NSAssert([user.ID isValid], @"invalid user: %@", user);
    if (user && ![_users containsObject:user]) {
        [_users addObject:user];
    }
    // check current user
    if (!_currentStation.currentUser) {
        _currentStation.currentUser = user;
    }
}

- (void)removeUser:(DIMLocalUser *)user {
    if ([_users containsObject:user]) {
        [_users removeObject:user];
    }
    // check current user
    if ([_currentStation.currentUser isEqual:user]) {
        _currentStation.currentUser = _users.firstObject;
    }
}

#pragma mark DIMStationDelegate

- (void)station:(DIMStation *)server didReceivePackage:(NSData *)data {
    // decode to reliable message
    NSDictionary *dict = [data jsonDictionary];
    DIMReliableMessage *rMsg = DKDReliableMessageFromDictionary(dict);
    
    // check sender
    DIMID *sender = DIMIDWithString(rMsg.envelope.sender);
    DIMMeta *meta = DIMMetaForID(sender);
    if (!meta) {
        meta = MKMMetaFromDictionary(rMsg.meta);
        if (!meta) {
            NSLog(@"meta for %@ not found, query from the network...", sender);
            [self queryMetaForID:sender];
            // TODO: insert the message to a temporary queue to waiting meta
            return ;
        }
    }
    
    // check receiver
    DIMID *receiver = DIMIDWithString(rMsg.envelope.receiver);
    DIMLocalUser *user = nil;
    if (MKMNetwork_IsGroup(receiver.type)) {
        // group message
        NSAssert(rMsg.group == nil || [DIMIDWithString(rMsg.group) isEqual:receiver],
                 @"group error: %@ != %@", receiver, rMsg.group);
        // check group membership
        DIMGroup *group = DIMGroupWithID(receiver);
        for (DIMLocalUser *item in self.users) {
            if ([group existsMember:item.ID]) {
                user = item;
                NSLog(@"got new message for: %@", item.ID);
                break;
            }
        }
        if (user) {
            // trim for current user
            rMsg = [rMsg trimForMember:user.ID];
        }
    } else {
        for (DIMLocalUser *item in self.users) {
            if ([item.ID isEqual:receiver]) {
                user = item;
                NSLog(@"got new message for: %@", item.ID);
                break;
            }
        }
    }
    if (!user) {
        NSAssert(false, @"!!! wrong recipient: %@", receiver);
        return ;
    }
    
    // trans to instant message
    DIMInstantMessage *iMsg = [[DIMMessanger sharedInstance] verifyAndDecryptMessage:rMsg];
    if (iMsg == nil) {
        NSLog(@"failed to verify/decrypt message: %@", rMsg);
        return ;
    }
    
    // process commands
    DIMContent *content = iMsg.content;
    if (content.type == DIMContentType_Command) {
        DIMCommand *cmd = (DIMCommand *)content;
        NSString *command = cmd.command;
        if ([command isEqualToString:DIMSystemCommand_Handshake]) {
            // handshake
            return [self processHandshakeCommand:(DIMHandshakeCommand *)cmd];
        } else if ([command isEqualToString:DIMSystemCommand_Meta]) {
            // query meta response
            return [self processMetaCommand:(DIMMetaCommand *)cmd];
        } else if ([command isEqualToString:DIMSystemCommand_Profile]) {
            // query profile response
            return [self processProfileCommand:(DIMProfileCommand *)cmd];
        } else if ([command isEqualToString:@"users"]) {
            // query online users response
            return [self processOnlineUsersCommand:cmd];
        } else if ([command isEqualToString:@"search"]) {
            // search users response
            return [self processSearchUsersCommand:cmd];
        } else if ([command isEqualToString:DIMSystemCommand_Receipt]) {
            // receipt
            DIMAmanuensis *clerk = [DIMAmanuensis sharedInstance];
            if ([clerk saveReceipt:iMsg]) {
                NSLog(@"target message state updated with receipt: %@", cmd);
            }
            return ;
        }
        NSLog(@"!!! unknown command: %@, sender: %@, message content: %@",
              command, sender, content);
        // NOTE: let the message processor to do the job
        //return ;
    } else if (content.type == DIMContentType_History) {
        DIMID *groupID = DIMIDWithString(content.group);
        if (groupID) {
            DIMGroupCommand *cmd = (DIMGroupCommand *)content;
            if (![self checkGroupCommand:cmd commander:sender]) {
                NSLog(@"!!! error group command from %@: %@", sender, content);
                return ;
            }
        }
        // NOTE: let the message processor to do the job
        //return ;
    }
    
    if (MKMNetwork_IsStation(sender.type)) {
        NSLog(@"*** message from station: %@", content);
        //return ;
    }
    
    // normal message, let the clerk to deliver it
    DIMAmanuensis *clerk = [DIMAmanuensis sharedInstance];
    [clerk saveMessage:iMsg];
}

@end
