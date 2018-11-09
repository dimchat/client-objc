# Decentralized Instant Messaging Client (Objective-C)

## User & Contacts:

* Implements your entity delegate (.h/.m)

```
#import "DIMC.h"

@interface AccountDelegate : NSObject <MKMUserDelegate, MKMContactDelegate, MKMEntityDataSource, MKMProfileDataSource>

+ (instancetype)sharedInstance;

@end
```
```
#import "AccountDelegate.h"

@implementation AccountDelegate

SingletonImplementations(AccountDelegate, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        [MKMBarrack sharedInstance].userDelegate = self;
        [MKMBarrack sharedInstance].contactDelegate = self;
        
        [MKMBarrack sharedInstance].entityDataSource = self;
        [MKMBarrack sharedInstance].profileDataSource = self;
    }
    return self;
}

#pragma mark - MKMUserDelegate

- (MKMUser *)userWithID:(const MKMID *)ID {
    MKMPublicKey *PK = MKMPublicKeyForID(ID);
    return [[MKMUser alloc] initWithID:ID publicKey:PK];
}

#pragma mark MKMContactDelegate

- (MKMContact *)contactWithID:(const MKMID *)ID {
    MKMPublicKey *PK = MKMPublicKeyForID(ID);
    return [[MKMContact alloc] initWithID:ID publicKey:PK];
}

#pragma mark - MKMEntityDataSource

- (MKMMeta *)metaForEntityID:(const MKMID *)ID {
    // TODO: load meta from local storage or network
    NSDictionary *dict;
    // ...
    return [[MKMMeta alloc] initWithDictionary:dict];;
}

#pragma mark - MKMProfileDataSource

- (MKMProfile *)profileForID:(const MKMID *)ID {
    // TODO: load profile from local storage or network
    NSDictionary *dict;
    // ...
    return [[MKMProfile alloc] initWithDictionary:dict];;
}

@end
```

### Samples
* Register User

```
// generate asymmetric keys
MKMPrivateKey *SK = [[MKMPrivateKey alloc] init];
MKMPublicKey *PK = SK.publicKey;

// register user
MKMUser *moky = [MKMUser registerWithName:@"moky" privateKey:SK publicKey:PK];
NSLog(@"my new ID: %@", moky.ID);

// set current user for the DIM client
[[DIMClient sharedInstance] setCurrentUser:moky];
```
1. The private key of the registered user will save into the Keychain automatically.
2. The meta & history of this user must be saved by the entity delegate after registered.

* Load User

```
// 1. Initialize your delegate first
[AccountDelegate sharedInstance];

// 2. Load user from barrack
NSString *str = @"moki@4LrJHfGgDD6Ui3rWbPtftFabmN8damzRsi";  // from your db
MKMID *ID = [[MKMID alloc] initWithString:str];
MKMUser *moky = [[MKMBarrack sharedInstance] userWithID:ID]; // from factory

// 3. Set current user for the DIM client
[[DIMClient sharedInstance] setCurrentUser:moky];
```
1. Your delegate must load the user data from local storage to create user,
2. After that it should try to query the newest history & profile from the network.

* Load Contact

```
// 1. Initialize your delegate first
[AccountDelegate sharedInstance];

// 2. Get contacts from barrack
MKMID *ID1 = [[MKMID alloc] initWithString:MKM_IMMORTAL_HULK_ID];
MKMID *ID2 = [[MKMID alloc] initWithString:MKM_MONKEY_KING_ID];
MKMContact *hulk = [[MKMBarrack sharedInstance] contactWithID:ID1];
MKMContact *moki = [[MKMBarrack sharedInstance] contactWithID:ID2];

// 3. Add contacts to the user
[moky addContact:hulk.ID];
[moky addContact:moki.ID];
```
1. Your delegate must load the contact data (or query from network) when need.
2. You need to manage the user's relationship, here just add the contacts to the user in memory, not persistent store.

## Instant messages:

* Implements the conversation(chatroom) data source & delegate

```
#import "DIMC.h"

@interface MessageProcessor : NSObject <DIMConversationDataSource, DIMConversationDelegate>

#pragma mark DIMConversationDataSource

// get message count in the conversation
- (NSInteger)numberOfMessagesInConversation:(const DIMConversation *)chatroom;

// get message at index of the conversation
- (DIMInstantMessage *)conversation:(const DIMConversation *)chatroom messageAtIndex:(NSInteger)index;

#pragma mark DIMConversationDelegate

// save new message to local db
- (void)conversation:(const DIMConversation *)chatroom didReceiveMessage:(const DIMInstantMessage *)iMsg;

@end
```

### Samples
* Send message

```
// 1. Create message content
NSString *text = @"Hey boy!"
DIMMessageContent *content = [[DIMMessageContent alloc] initWithText:text];

// 2. Encrypt and sign the message content by transceiver
DIMTransceiver *trans = [DIMTransceiver sharedInstance];
DIMCertifiedMessage *cMsg = [trans encryptAndSignContent:content sender:moky.ID receiver:hulk.ID];

// 3. Send out the certified secure message via current connection
NSData *data = [cMsg jsonData];
// TODO: compress(optional) and send out
// ...
```

* Receive message

```
// create your message processor
_myMessageProcessor = [[MessageProcessor alloc] init];

// set to the conversation manager
DIMAmanuensis *clerk = [DIMAmanuensis sharedInstance];
clerk.dataSource = _myMessageProcessor;
clerk.delegate = _myMessageProcessor;

// 1. when your network connection received a message data, you should
//    decompress(if need) and call [DIMTransceiver sharedInstance]
//    to verify and decrypt it to an InstantMessage;
// 2. after that, you could try to recognize the message type, if it is
//    a system command, you could run your scripts for it, otherwise
//    call [DIMClient sharedInstance] to handle the message;
// 3. the client will insert it into the chat box (DIMConversation)
//    that the message belongs to;
// 4. finally, the chat box will call your message processor to save it,
//    the clerk (DIMAmanuensis) will set your processor into each chat box
//    automatically, unless you have already specify them.
```
1. Your message processor should implement saving new message and loading messages partially from local store.

---
Written by [Albert Moky](http://moky.github.com/) @2018
