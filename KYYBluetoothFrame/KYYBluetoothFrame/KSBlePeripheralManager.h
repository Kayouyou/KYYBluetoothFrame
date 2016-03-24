//
//  KSLulockBleDevice.h
//  Lulock
//
//  Created by Melo on 7/8/15.
//  Copyright (c) 2015 geil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "KSBleCalibration.h"
#import "KSBleConnectionTask.h"
#import "MainFunctionController.h"
CB_EXTERN BOOL const KSBleTaskOptionImmediateTaskKey;
CB_EXTERN BOOL const KSBleTaskOptionForeverTaskKey;
CB_EXTERN NSTimeInterval * const KSBleTaskOptionAdvertisementTimeoutKey;


typedef enum {
    KSBlePeripheralManagerStatePowerOff,         // 关闭被关闭，需要手动打开
    KSBlePeripheralManagerStatePowerOn,          // 蓝牙刚打开，未初始化连接
    KSBlePeripheralManagerStateAdvertising,      // Peripheral正在广播
    KSBlePeripheralManagerStateConnected,        // Central注册了订阅，建立了数据连接，可以开始传输数据
    KSBlePeripheralManagerStateTransmitting,     // 正在传输数据
    KSBlePeripheralManagerStateDisconnected,     // Central取消了订阅，意味着失去了连接
} KSBlePeripheralManagerState;

typedef void (^AddBleServiceCompletion)(NSError *);
typedef void (^KSOpenOrCloseAutoUnlockCallBack)(BOOL status);


@protocol KSBlePeripheralManagerStatus <NSObject>

@optional

- (void)bluetoothIsEnable:(BOOL)isEnabled;

- (void)autoUnlocKeepAdvertising;//保持自动开锁的回调

- (void)centralDisconnect;

@end



@interface KSBlePeripheralManager :NSObject <CBPeripheralDelegate, CBPeripheralManagerDelegate,MainViewControllerProtocol> {

}

@property (nonatomic, assign, readonly) KSBlePeripheralManagerState state;
@property (nonatomic,strong) KSOpenOrCloseAutoUnlockCallBack  autoStatus;
@property (nonatomic,weak)id<KSBlePeripheralManagerStatus>delegate;
@property (nonatomic,assign)NSInteger operationType;

+ (instancetype)sharedInstance;

+ (id)getRestoreManagerWithLaunchOptions:(NSDictionary *)launchOptions;

- (void)startRestoredAdvertising;
- (void)addService:(CBMutableService *)service completion:(AddBleServiceCompletion)completion;
- (void)removeService:(CBMutableService *)service;
- (void)stopAdvertising;
- (void)closeAutoUnlock;
/**
 *  注册一个连接任务，对任务进行排队
 *
 *  @param options    连接选项，包含多个键值指明操作过程，有如下选项：
 *  @discussion       (BOOL)KSBleTaskOptionForeverTaskKey 任务属于后台永久的任务，目前只能有一个
 *                    (NSNumber *)KSBleTaskOptionAdvertisementTimeoutKey 持续广播的超时时间
 *                    (BOOL)KSKSBleTaskOptionImmediateTaskKey 立即任务，不排队
 */
- (void)runTask:(KSBleConnectionTask *)task options:(NSDictionary *)options;
- (void)quitTask:(KSBleConnectionTask *)task;





@end
