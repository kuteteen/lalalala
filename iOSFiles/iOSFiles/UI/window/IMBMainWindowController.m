//
//  IMBMainWindowController.m
//  AnyTrans
//
//  Created by LuoLei on 16-7-13.
//  Copyright (c) 2016年 imobie. All rights reserved.
//

#import "IMBMainWindowController.h"
#import "IMBNoTitleBarWindow.h"
#import "StringHelper.h"
#import "IMBDeviceViewController.h"
@interface IMBMainWindowController ()

@end

@implementation IMBMainWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName {
    if (self = [super initWithWindowNibName:windowNibName]) {
     
    }
    return self;
}

- (void)awakeFromNib {
    NSRect screenRect = [NSScreen mainScreen].frame;
    [self.window setMaxSize:NSMakeSize(screenRect.size.width, screenRect.size.height)];
    [self.window setMinSize:NSMakeSize(1060, 635)];

    [(NSView *)((IMBNoTitleBarWindow *)self.window).maxAndminView setFrameOrigin:NSMakePoint(10,NSHeight(_topView.frame) - 36)];
    [[(IMBNoTitleBarWindow *)self.window closeButton] setAction:@selector(closeWindow:)];
    [[(IMBNoTitleBarWindow *)self.window closeButton] setTarget:self];
    [_topView addSubview:((IMBNoTitleBarWindow *)self.window).maxAndminView];
    [_topView initWithLuCorner:YES LbCorner:NO RuCorner:YES RbConer:NO CornerRadius:5];
    [_topView setWantsLayer:YES];
    [_topView.layer setBackgroundColor:[NSColor colorWithDeviceRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1].CGColor];
    
    IMBDeviceViewController *deviceViewController = [[IMBDeviceViewController alloc]initWithNibName:@"IMBDeviceViewController" bundle:nil];
    [_rootBox addSubview:deviceViewController.view];
    [deviceViewController release];
    deviceViewController = nil;
}

- (void)closeWindow:(id)sender {
    [self.window close];
}

@end
