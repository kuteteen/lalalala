//
//  IMBDeviceViewController.m
//  AnyTrans
//
//  Created by LuoLei on 16-7-13.
//  Copyright (c) 2016年 imobie. All rights reserved.
//

#import "IMBDeviceViewController.h"
#import "IMBDisconnectViewController.h"
#import "IMBDeviceConnection.h"


@interface IMBDeviceViewController ()



@end

@implementation IMBDeviceViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

/**
 * 初始化操作
 */
- (void)awakeFromNib {
    [self setupView];
    [self deviceConnection];
    
}

- (void)setupView {
    IMBDisconnectViewController *disConnectController = [[IMBDisconnectViewController alloc]initWithNibName:@"IMBDisconnectViewController" bundle:nil];
    [_deviceBox addSubview:disConnectController.view];
    [disConnectController release];
    disConnectController = nil;
    
    
}

- (void)deviceConnection {
    
    IMBDeviceConnection *deviceConnection = [IMBDeviceConnection singleton];
    [deviceConnection startListening];
    
//    __block typeof(self) weakSelf = self;
    deviceConnection.IMBDeviceConnected = ^{
        //设备连接成功
        [self deviceConnected];
    };
    deviceConnection.IMBDeviceDisconnected = ^(NSString *serialNum){
        //设备断开连接
        [self deviceDisconnected:serialNum];
    };
    deviceConnection.IMBDeviceNeededPassword = ^(am_device device){
        //设备连接需要密码
        [self deviceNeededPwd:device];
    };
}

- (void)dealloc {
    [[IMBDeviceConnection singleton] stopListening];
    
    [super dealloc];
}

#pragma mark -- 设备连接状态
/**
 *  设备连接成功
 */
- (void)deviceConnected {
    
}
/**
 *  设备断开连接
 */
- (void)deviceDisconnected:(NSString *)serialNum {
    
}
/**
 *  设备连接需要密码
 */
- (void)deviceNeededPwd:(am_device)device {
    
}
@end
