//
//  KSLuggageCaseLock.h
//  Lulock
//
//  Created by Melo on 15/8/3.
//  Copyright (c) 2015年 geil. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KSBlePeripheralManager;
#import "Entity.h"
@class CoreDataManager;
typedef void (^manualUnlockError) (BOOL  error,NSInteger battery);
typedef void (^autoUnlockError) (NSError *error,NSInteger battery);
typedef void (^unlockMemoryError) (NSError *error,NSArray *records);
typedef void (^calibrationError) (NSError *error);
typedef void (^antiLostError) (NSError *error,BOOL alarmOrNot,NSInteger mOrA);
typedef void (^modifyKeyError) (BOOL state);
typedef void (^queryError) (NSError *error,NSArray *infoArray);
typedef void (^getbackPwdError) (BOOL status, NSData *pwd);
typedef void (^queryKeyListError) (BOOL status, NSMutableArray *keyArray);
typedef void (^changeKeyStatusError) (BOOL status);
typedef void (^deleteKeyError) (BOOL status);
typedef void (^renameKeyError) (BOOL status);

@interface KSLuggageCaseLock : NSObject
@property (nonatomic,strong)  KSBleConnectionTask *task;
@property (nonatomic, strong) KSBlePeripheralManager *device;
@property (nonatomic,strong) NSMutableData *configureData;
@property (nonatomic,strong) NSMutableArray *alarmDistance;
@property (nonatomic,assign) NSInteger currentDistance;
@property (nonatomic,assign) BOOL isSucMark;
@property (nonatomic,assign) BOOL isAlarmAudioPlaying;
@property (nonatomic,strong)  NSMutableArray *measuredPowerArray;
@property (nonatomic,strong) CoreDataManager *manager;


+ (instancetype)sharedInstance;

- (void)pairingKeyWithPWD:(NSString *)passWord andCompletion:(void(^)(NSError*error))completion;
- (void)manualUnlockWithKey:(Entity *)key andCompletion:(manualUnlockError)completion;
- (void)autoUnlockWithKey:(Entity *)key andCompletion:(autoUnlockError)completion;
- (void)unlockMemoryWithKey:(Entity *)key andCompletion:(unlockMemoryError)completion;
- (void)RSSICalibrationWithCurrentKey:(Entity *)key andCompletion:(calibrationError)completion;
- (void)antiLostWithCurrentKey:(Entity *)key withAntilostDistance:(NSInteger )currentDistance andComplation:(antiLostError)completion;
- (void)manageKeysWithKey:(Entity *)key oldPWD:(NSString *)oldPwd newPWD:(NSString *)newPwd andCompletion:(modifyKeyError)completion;
- (void)queryMoreInfoWithKey:(Entity *)key andCompletion:(queryError)completion;
- (void)getBackManagerPWDWithKey:(Entity *)key withQRInfo:(NSString *)qrInfo andCompletion:(getbackPwdError)completion;
- (void)queryKeyListWithKey:(Entity *)key andCompletion:(queryKeyListError)completion;

- (void)changeKeyStatusWithKey:(Entity *)key withPWD:(NSString *)passWord   withHandledKeyId:(uint8_t)keyId withStatus:(NSNumber *)status andCompletion:(changeKeyStatusError) completion;

- (void)deleteKeyWithKey:(Entity *)key withPWD:(NSString *)passWord withHandledKeyId:(uint8_t)keyId andCompletion:(deleteKeyError) completion;

- (void)renameKeyWithKey:(Entity *)key withPWD:(NSString *)passWord withHandledKeyId:(uint8_t)keyId withNewName:(NSString *)newName andCompletion:(renameKeyError) completion;



@end
