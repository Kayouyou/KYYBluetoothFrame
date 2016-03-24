//
//  KSLuggageCaseLock.m
//  Lulock
//
//  Created by Melo on 15/8/3.
//  Copyright (c) 2015年 geil. All rights reserved.
//

#import "KSLuggageCaseLock.h"
#import "KSBleConnectionTask.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"

@implementation KSLuggageCaseLock{
    NSData *writeData;
    uint8_t server_otp[2];
    uint8_t timestamp[4];
    NSData *user_key;
    NSData *user_data_owner;
    NSData *user_data_guest;
    NSData *ccm_nonce;
    BOOL    isGetNonce;
    BOOL    isGetkey;
    BOOL    toUnlock;

    float alarmDistanceOffset;
    
    BOOL isAlarming;
    SystemSoundID alarmAudio;
    BOOL isAlarmAudioInit;
    
    BOOL isAntiLost;
    uint8_t key_id;
    NSData *phoneID;
    NSString *centralIdentifier;
    NSUserDefaults *UD;
   
    NSInteger currentKeyNum;
    NSInteger currentBattery;
}

+ (instancetype)sharedInstance{
    
    static KSLuggageCaseLock *instance = nil;
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
       
        instance = [[self alloc]init];
        
    });
    return instance;
}


- (id)init {
    self = [super init];
    if (self) {
//        self.device = [AppDelegate shareAppDelegate].pmanager;
    }
    return self;
}

#pragma mark - 使用例子
- (void)pairingKeyWithPWD:(NSString *)passWord andCompletion:(void(^)(NSError*error))completion {
    
    
}




@end
