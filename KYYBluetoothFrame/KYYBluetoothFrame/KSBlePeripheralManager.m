//  KSBlePeripheralManager.m
//  Lulock
//
//  Created by Melo on 7/8/15.
//  Copyright (c) 2015 geil. All rights reserved.
//

#import "KSBlePeripheralManager.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "KSBleConnectionTask.h"
#import "KSLuggageCaseLock.h"
#import "AppDelegate.h"
static int kAdvertisingForever = 0;
static NSTimeInterval kAdvertisementTimeIntervalDefeault = 5.0;
static NSString * const kLulockPeripheralManagerOptionRestoreIdentifierKey = @"com.knowsight.Walnut";
static dispatch_once_t kBleConnectionTaskOptionsDefaultPredicate;
static NSDictionary *kBleConnectionTaskOptionsDefault = nil;
static KSBleConnectionTask *currentTask  = nil;//静态的变量
static dispatch_semaphore_t restoreSemaphore = 0;//获取APP推出前保存的广播信息的信号量
 static KSBlePeripheralManager *instance = nil;
@interface KSBlePeripheralConnectionTask : NSObject
@property (nonatomic, weak) KSBleConnectionTask *task;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, assign) BOOL isForbidden;

- (instancetype)init:(KSBleConnectionTask *)task NS_DESIGNATED_INITIALIZER;
@end

@implementation KSBlePeripheralConnectionTask

- (instancetype)init:(KSBleConnectionTask *)task {
    self = [super init];
    if (self) {
        self.task = task;
        self.isForbidden = YES;
        self.isRunning = NO;
    }
    
    return self;
}

@end

@implementation KSBlePeripheralManager {
    CBPeripheralManager *perManager;
    KSBleConnectionTask *foreverTask;
    KSLuggageCaseLock *lock1;
    AddBleServiceCompletion addServiceCompletion;
    BOOL defaultAutoUnlock;
    BOOL autoUnlock;
    BOOL manualUnlock;
    BOOL serviceAdding;
    NSLock *lock;
    CBCentral *subscribedCentral;
    CBMutableCharacteristic *subcribedCharact;
    BOOL advertisingForever;
    BOOL calibrationIsOk;//验证校准
    BOOL antilost;
    BOOL isRestored;
    NSDictionary *restoredAdvertiseData;

    NSUserDefaults *UD;
    CoreDataManager *manager;
    
}

+ (instancetype)sharedInstance{
   
    dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
       
        instance = [[self alloc]init];
        
    });
    
    return instance;
    
}

- (id)initWithLaunchingOptions:(NSDictionary *)launchingOptions{
    
    self = [super init];
    
    if (self) {
    
       restoreSemaphore = dispatch_semaphore_create(0);
        NSArray *peripheralManagerIdentifiers = launchingOptions[UIApplicationLaunchOptionsBluetoothPeripheralsKey];
        
        autoUnlock = YES;
    //1,被系统杀死保存了状态值
    if (peripheralManagerIdentifiers  && [peripheralManagerIdentifiers count]>0) {
        
        for (NSString *identifier in peripheralManagerIdentifiers) {
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            //创建一个从实例从option中获取的值去恢复peripheral的状态
            if (perManager) {
                
                perManager = nil;
                perManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:queue options:@{CBPeripheralManagerOptionRestoreIdentifierKey:identifier}];
            }else{
                 perManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:queue options:@{CBPeripheralManagerOptionRestoreIdentifierKey:identifier}];
                
            }
            

            break;//一个APP只用一个manager
        }
    }else{
        
           perManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil options:@{CBPeripheralManagerOptionRestoreIdentifierKey:kLulockPeripheralManagerOptionRestoreIdentifierKey}];
        
        
    }
    
    }

    return self;
    
    
}


- (void)startRestoredAdvertising{
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        dispatch_semaphore_wait(restoreSemaphore, DISPATCH_TIME_FOREVER);
    
    [perManager startAdvertising:restoredAdvertiseData];

    });
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        restoredAdvertiseData = [[NSMutableDictionary alloc]init];
        //currentTask = [[KSBleConnectionTask alloc]init];
        _state = KSBlePeripheralManagerStatePowerOff;
        
        perManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil options:@{CBPeripheralManagerOptionRestoreIdentifierKey:kLulockPeripheralManagerOptionRestoreIdentifierKey}];
       
        subscribedCentral = nil;
        serviceAdding = NO;
        lock = [[NSLock alloc] init];
        advertisingForever = NO;
        autoUnlock = NO;
        defaultAutoUnlock = YES;//默认自动开锁模式
        calibrationIsOk  = NO;
        manualUnlock = NO;
        antilost = NO;
        dispatch_once(&kBleConnectionTaskOptionsDefaultPredicate, ^{
            kBleConnectionTaskOptionsDefault = @{@"KSBleTaskOptionForeverTaskKey": @"NO",
                                                 @"KSBleTaskOptionAdvertisementTimeoutKey": @"5",
                                                 @"KSKSBleTaskOptionImmediateTaskKey": @"YES",};
    
        });
               
    }
    return self;
}


#pragma mark - CBPeripheralDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
   
    switch (peripheral.state) {
            
        case CBPeripheralManagerStatePoweredOn:
    
            break;
        case CBPeripheralManagerStatePoweredOff:
            
            break;
        case CBPeripheralManagerStateResetting:
            break;
        case CBPeripheralManagerStateUnauthorized:
            break;
        case CBPeripheralManagerStateUnsupported:
            break;
        case CBPeripheralManagerStateUnknown:
           
            break;
        default:
           
            break;
    }
}


#pragma mark - runTask
- (void)runTask:(KSBleConnectionTask *)task options:(NSDictionary *)options {
    
    
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {

}

#pragma mark - CBPeripheralManagerDelegate
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSString *identifier = [central.identifier UUIDString];

    if (currentTask.notification) {
        
    BOOL ready = [perManager updateValue:(NSData *)currentTask.notification forCharacteristic:subcribedCharact onSubscribedCentrals:@[central]];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    // Central取消订阅，意味着其马上断开连接或者不再读写数据，从高层抽象来看，本次连接已经断开了

}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    
    
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    NSMutableData *result = [[NSMutableData alloc] init];
    [result setLength:0];
    
    for (CBATTRequest *request in requests) {
        [result appendData:request.value];
        [perManager respondToRequest:request withResult:CBATTErrorSuccess];
    }

    if (currentTask && currentTask.receiveCallback) {
     
        currentTask.receiveCallback(result,requests);

    }
    
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    
    NSMutableData *configureData = [NSMutableData new];
    configureData =  currentTask.receivedReadCallback();
    
    if (configureData) {
        if (request.offset > [configureData length]) {
            [peripheral respondToRequest:request withResult:CBATTErrorInvalidOffset];
            return;
        }
        request.value = [configureData subdataWithRange:NSMakeRange(request.offset, configureData.length - request.offset)];
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }
}

#pragma mark -应用后台被回收后状态恢复的回调操作
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict {
    
    isRestored = YES;

    restoredAdvertiseData = dict[CBPeripheralManagerRestoredStateAdvertisementDataKey];
    
    dispatch_semaphore_signal(restoreSemaphore);
}



@end
