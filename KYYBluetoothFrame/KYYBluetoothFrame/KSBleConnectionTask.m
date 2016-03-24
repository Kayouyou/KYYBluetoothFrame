//
//  KSBleConnectionTask.m
//  Lulock
//
//  Created by Melo on 15/8/7.
//  Copyright (c) 2015年 geil. All rights reserved.
//

#import "KSBleConnectionTask.h"


@implementation KSBleConnectionTask


+ (KSBleConnectionTask *)sharedInstance{
    static KSBleConnectionTask *sharedTask = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
       
        sharedTask = [KSBleConnectionTask new];
        
    });
    
    return sharedTask;
}

@end
