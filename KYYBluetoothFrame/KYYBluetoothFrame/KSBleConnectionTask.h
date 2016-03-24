//
//  KSBleConnectionTask.h
//  Lulock
//
//  Created by Melo on 15/8/7.
//  Copyright (c) 2015年 geil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef enum  {
    KSBleConnectionTaskStateRuning,
    KSBleConnectionTaskStateFinish,
} KSBleConnectionTaskState;

typedef void (^KSBleConnectionTaskReceiveWriteCallback)(NSMutableData *response,NSArray *requests);
typedef id (^KSBleConnectionTaskReceiveReadCalllback)();
typedef void (^KSBleConnectionTaskDisconnectCallback)(NSMutableData *response);
typedef void (^KSBleConnectionTaskErrorCallback)(NSError *error);
typedef void (^KSBleConnectionTaskReceiveConncetCallBack)(NSString *cIdentifier);


@interface KSBleConnectionTask : NSObject


@property (nonatomic, strong) NSDictionary *advertisement;
@property (nonatomic, strong) CBService *service;
@property (nonatomic, strong) NSMutableData *notification;
@property (nonatomic, strong) KSBleConnectionTaskReceiveReadCalllback receivedReadCallback;
@property (nonatomic, assign) KSBleConnectionTaskState state;
@property (nonatomic, weak) NSDictionary *taskOptions;
@property (nonatomic, strong) KSBleConnectionTaskReceiveWriteCallback receiveCallback;
@property (nonatomic, strong) KSBleConnectionTaskDisconnectCallback disconnectCallback;
@property (nonatomic, strong) KSBleConnectionTaskErrorCallback errorCallback;
@property (nonatomic, strong)KSBleConnectionTaskReceiveConncetCallBack receivedConnectCallBack;

+ (KSBleConnectionTask *)sharedInstance;
@end
