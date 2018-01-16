//
//  IMBDeviceConnection.m
//  iOSFiles
//
//  Created by iMobie on 18/1/16.
//  Copyright © 2018年 iMobie. All rights reserved.
//

#import "IMBDeviceConnection.h"


static id _instance = nil;

@interface IMBDeviceConnection()<NSCopying,MobileDeviceAccessListener>

@property(nonatomic, retain)MobileDeviceAccess *deviceAccess;

@end

@implementation IMBDeviceConnection


#pragma mark -- 单例实现
+ (instancetype)singleton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[IMBDeviceConnection alloc] init];
    });
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

- (void)dealloc {
    
    [_serialArray release];
    _serialArray = nil;
    
    [super dealloc];
}
#pragma mark --  初始化操作

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}
/**
 *  初始化操作
 */
- (void)setUp {
    _serialArray = [[NSMutableArray alloc] init];//这里尽量不要用[NSMutableArray array];这种方法进行创建，这种方法容易造成crash
    _deviceAccess = [MobileDeviceAccess singleton];
}

/**
 *  开始监听
 */
- (void)startListening {
    [self.deviceAccess setListener:self];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(mountNotification:) name:NSWorkspaceDidMountNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(unmountNotification:) name:NSWorkspaceDidUnmountNotification object:nil];
}
/**
 *  断开监听
 */
- (void)stopListening {
    [self.deviceAccess stopListener];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidMountNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidUnmountNotification object:nil];
}

#pragma mark --  通知方法

- (void)mountNotification:(NSNotification *)noti {
    
}

- (void)unmountNotification:(NSNotification *)noti {
    
}
#pragma mark --  设备连接监听方法
/**
 *  设备成功连接
 *
 *  @param device 设备
 */
- (void)deviceConnected:(AMDevice *)device {
    IMBFFuncLog;
    if (device) {
        if (self.IMBDeviceConnected) {
            self.IMBDeviceConnected();
        }
        NSString *deviceSerialNumber = ((AMDevice *)device).serialNumber;
        if (deviceSerialNumber) {
            [self.serialArray addObject:deviceSerialNumber];
        }
        
        device.isValid = YES;
//        [_processingQueue addOperationWithBlock:^(void){
//            sleep(2);
//            if ([_servialArray containsObject:deviceSerialNumber]) {
//                [self createIPodByDevice:device];
//            }
//        }];
    }else {
        NSLog(@"preSerialNumber is nil");
    }
}
/**
 *  设备断开连接
 *
 *  @param device 设备
 */
- (void)deviceDisconnected:(AMDevice *)device {
    IMBFFuncLog;
    device.isValid = NO;
    NSString *serialNumber = [device serialNumber];
    if ([self.serialArray containsObject:serialNumber]) {
        [self.serialArray removeObject:serialNumber];
    }
    
    if (_IMBDeviceDisconnected) {
        _IMBDeviceDisconnected(serialNumber);
    }
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                              seriaNumber, @"UniqueKey"
//                              , nil];
//    [nc postNotificationName:DeviceBtnChangeNotification object:[NSNumber numberWithBool:NO] userInfo:userInfo];
//    [nc postNotificationName:DeviceDisConnectedNotification object:seriaNumber userInfo:userInfo];
}
/**
 *  设备需要密码
 *
 *  @param device 设备
 */
- (void)deviceNeedPassword:(am_device)device {
    IMBFFuncLog;
    if (self.IMBDeviceNeededPassword) {
        self.IMBDeviceNeededPassword(device);
    }
}

/**
 *  是否支持wifi连接
 *
 *  @return 设备
 */

- (BOOL)canSupportWifi {
    return NO;
}


@end