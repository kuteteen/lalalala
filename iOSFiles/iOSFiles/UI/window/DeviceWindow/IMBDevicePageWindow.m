//
//  IMBDevicePageWindow.m
//  iOSFiles
//
//  Created by 龙凡 on 2018/1/31.
//  Copyright © 2018年 iMobie. All rights reserved.
//

#import "IMBDevicePageWindow.h"
//#import "IMBNoTitleBarWindow.h"
#import "IMBDrawOneImageBtn.h"
#import "IMBToolbarWindow.h"
#import "IMBiPod.h"
#import "IMBInformation.h"
#import "IMBInformationManager.h"
#import "IMBCommonEnum.h"
#import "IMBTrack.h"
#import "IMBPhotoEntity.h"
#import "IMBDeviceConnection.h"
#import "IMBBooksManager.h"
#import "IMBBookEntity.h"
#import "IMBApplicationManager.h"
#import "IMBAppEntity.h"
#import "IMBDevicePageFolderModel.h"

static CGFloat const rowH = 40.0f;
static CGFloat const labelY = 10.0f;

@interface IMBDevicePageWindow ()<NSTabViewDelegate,NSTableViewDataSource>
{
    @private
    IMBInformation *_information;
    NSOperationQueue *_opQueue;
    NSMutableArray *_dataArray;
    NSArray *_headerTitleArr;
    NSArray *_folderNameArray;
    
    IBOutlet NSScrollView *_scrollView;
    IBOutlet NSTableView *_tableView;
}
@end

@implementation IMBDevicePageWindow

//- (void)windowDidLoad {
//    [super windowDidLoad];
//    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
//}

- (id)initWithiPod:(IMBiPod *)ipod {
    if ([super initWithWindowNibName:@"IMBDevicePageWindow"]) {
        _iPod = [ipod retain];
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    
    NSButton *btn =  [self.window standardWindowButton:NSWindowCloseButton];
//    [btn setFrame:NSMakeRect(2,4, 20, 20)];
//    NSButton *btn1 =  [self.window standardWindowButton:NSWindowMiniaturizeButton];
//    [btn1 setFrame:NSMakeRect(6,10, 20, 20)];
    NSButton *btn2 =  [self.window standardWindowButton:NSWindowZoomButton];
//    [btn2 setFrame:NSMakeRect(0,0, 20, 20)];
//    [btn setHidden:YES];
//    [btn1 setHidden:YES];
    
    
    [btn2 setAction:@selector(zoomWindow:)];
    [btn2 setTarget:self];
    
    [btn setAction:@selector(closeWindow:)];
    [btn setTarget:self];
    
    [_title setStringValue:_iPod.deviceInfo.deviceName];
    
    
//    IMBDrawOneImageBtn *button = [[IMBDrawOneImageBtn alloc]initWithFrame:NSMakeRect(12, 2, 12, 12)];
//    [button mouseDownImage:[NSImage imageNamed:@"windowclose3"] withMouseUpImg:[NSImage imageNamed:@"windowclose"] withMouseExitedImg:[NSImage imageNamed:@"windowclose"] mouseEnterImg:[NSImage imageNamed:@"windowclose2"]];
//    [button setEnabled:YES];
//    [button setTarget:self];
//    [button setAction:@selector(closeWindow:)];
//    [button setBordered:NO];
//    [[(IMBToolbarWindow *)self.window titleBarView]addSubview:btn2];
    
    [(IMBToolbarWindow *)self.window setTitleBarHeight:100];
//    [[(IMBToolbarWindow *)self.window titleBarView] setFrameSize:NSMakeSize(self.window.frame.size.width, 300)];
    
    [self setupView];

}

- (void)setup {
    if (_opQueue) {
        [_opQueue release];
        _opQueue = nil;
    }
    if (_dataArray) {
        [_dataArray release];
        _dataArray = nil;
    }
    
    _dataArray = [[NSMutableArray alloc] init];
    
    if (!_headerTitleArr) {
        NSString *path = [[NSBundle mainBundle] pathForResource:IMBDevicePageHeaderTitleNamesPlist ofType:nil];
        _headerTitleArr = [NSArray arrayWithContentsOfFile:path];
        
        path = [[NSBundle mainBundle] pathForResource:IMBDevicePageFolderNamesPlist ofType:nil];
        _folderNameArray = [NSArray arrayWithContentsOfFile:path];
    }
    if (_folderNameArray.count) {
        for (NSString *name in _folderNameArray) {
            static NSInteger idx = 0;
            IMBDevicePageFolderModel *model = [[[IMBDevicePageFolderModel alloc] init] autorelease];
            model.name = name;
            model.idx = idx++;
            [_dataArray addObject:model];
        }
    }
    
    _opQueue = [[NSOperationQueue alloc] init];
    [_opQueue setMaxConcurrentOperationCount:4];
    
    _information = [[IMBInformation alloc] initWithiPod:_iPod];
    
    
    [_opQueue addOperationWithBlock:^{
        if (_information) {
            
            NSArray *trackArray = [[NSMutableArray alloc] initWithArray:[_information getTrackArrayByMediaTypes:[IMBCommonEnum categoryNodeToMediaTyps:Category_Music]]];
            
            [self setDataArrayWithType:@"Media" handle:^(IMBDevicePageFolderModel *model) {
                model.trackArray = [trackArray retain];
            }];
            
            IMBFLog(@"%@",trackArray);
            for (IMBTrack *track in trackArray) {
                IMBFLog(@"%@",track);
            }
            
            trackArray = [[NSMutableArray alloc] initWithArray:[_information getTrackArrayByMediaTypes:[IMBCommonEnum categoryNodeToMediaTyps:Category_Movies]]];
            
            [self setDataArrayWithType:@"Video" handle:^(IMBDevicePageFolderModel *model) {
                model.trackArray = [trackArray retain];
            }];
            
            
            IMBFLog(@"%@",trackArray);
            for (IMBTrack *track in trackArray) {
                IMBFLog(@"%@",track);
            }
            
            [trackArray release];
            trackArray = nil;
            
        }
    }];
    
    [_opQueue addOperationWithBlock:^{
        if (_information) {
            [_information refreshCameraRoll];
            [_information refreshPhotoLibrary];
            [_information refreshPhotoStream];
            
            NSMutableArray *photoArray = [[NSMutableArray alloc] init];
            [photoArray addObjectsFromArray:[_information camerarollArray]];
            [photoArray addObjectsFromArray:[_information photolibraryArray]];
            [photoArray addObjectsFromArray:[_information photostreamArray]];
            
            [self setDataArrayWithType:@"Photo" handle:^(IMBDevicePageFolderModel *model) {
                model.photoArray = [photoArray retain];
            }];
            
            
            IMBFLog(@"%@",photoArray);
            for (IMBPhotoEntity *photo in photoArray) {
                IMBFLog(@"%@",photo);
            }
            [photoArray release];
            photoArray = nil;
        }
    }];
    
    [_opQueue addOperationWithBlock:^{
        if (_information) {
            [_information loadiBook];
            NSArray *ibooks = [[_information allBooksArray] retain];
            
            [self setDataArrayWithType:@"Book" handle:^(IMBDevicePageFolderModel *model) {
                model.booksArray = [ibooks retain];
            }];
            
            
            for (IMBBookEntity *book in ibooks) {
                IMBFLog(@"%@",book);
            }
            [ibooks release];
            ibooks = nil;
        }
    }];
    
    [_opQueue addOperationWithBlock:^{
        if (_information) {
            IMBApplicationManager *appManager = [[_information applicationManager] retain];
            [appManager loadAppArray];
            NSArray *appArray = [appManager appEntityArray];
            
            [self setDataArrayWithType:@"Apps" handle:^(IMBDevicePageFolderModel *model) {
                model.appsArray = [appArray retain];
            }];
            
            
            IMBFLog(@"%@",appArray);
            for (IMBAppEntity *app in appArray) {
                IMBFLog(@"%@",app);
            }
            
            
            [appArray release];
            appArray = nil;
            
            [appManager release];
            appManager = nil;
        }
    }];
}

- (void)setDataArrayWithType:(NSString *)type handle:(void(^)(IMBDevicePageFolderModel *model))handleBlock {
    for (IMBDevicePageFolderModel *model in _dataArray) {
        if ([model.name isEqualToString:type]) {
            if (handleBlock) {
                handleBlock(model);
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [_tableView endUpdates];
                
                [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:model.idx] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
//                [_tableView reloadData];
            });
            break;
        }
    }
}

/**
 *  设置view
 */
- (void)setupView {
    NSInteger count = _tableView.tableColumns.count;
    for (NSInteger i = 0; i < count; i++) {
        [_tableView removeTableColumn:_tableView.tableColumns[0]];
    }
    _scrollView.hasHorizontalScroller = NO;
    
    
    if (!_headerTitleArr) {
        NSString *path = [[NSBundle mainBundle] pathForResource:IMBDevicePageHeaderTitleNamesPlist ofType:nil];
        _headerTitleArr = [NSArray arrayWithContentsOfFile:path];
    }
    
    if (_headerTitleArr.count) {
        NSInteger count = _headerTitleArr.count;
        CGFloat cW = _tableView.frame.size.width/count;
        for (NSInteger i = 0; i < count; i++) {
            NSTableHeaderCell *cell = [[NSTableHeaderCell alloc] initTextCell:_headerTitleArr[i]];
            cell.alignment = NSCenterTextAlignment;
            NSTableColumn * column = [[NSTableColumn alloc] initWithIdentifier:_headerTitleArr[i]];
            
            [column setHeaderCell:cell];
            [column setWidth:cW];
            [_tableView addTableColumn:column];
        }
        
    }
}

-(void)dealloc {
    
    if (_information) {
        [_information release];
        _information = nil;
    }
    
    if (_opQueue) {
        [_opQueue release];
        _opQueue = nil;
    }
    
    if (_iPod) {
        [_iPod release];
        _iPod = nil;
    }
    
    if (_dataArray) {
        [_dataArray release];
        _dataArray = nil;
    }
    
    if (_headerTitleArr) {
        [_headerTitleArr release];
        _headerTitleArr = nil;
    }
    
    [super dealloc];
}

- (void)zoomWindow:(id)sender {

}

- (void)closeWindow:(id)sender {
    IMBDeviceConnection *deviceConnection = [IMBDeviceConnection singleton];
    for (IMBBaseInfo *baseInfo in deviceConnection.allDevices) {
        if ([baseInfo.uniqueKey isEqualToString:_iPod.uniqueKey]) {
            baseInfo.isSelected = NO;
        }
    }
    [self.window close];
}

#pragma mark --  NSTabViewDelegate,NSTableViewDataSource

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    return nil;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _dataArray.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return rowH;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return NO;
}


//- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes {
//    if ([proposedSelectionIndexes count] == 1) {
//        [proposedSelectionIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
//            self.selectedIndex = idx;
//            self.selectedTrack = [_dataArray objectAtIndex:idx];
//        }];
//    }else {
//        self.selectedIndex = -1;
//    }
//    return proposedSelectionIndexes;
//}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *strIdt = [tableColumn identifier];
    NSTableCellView *aView = [tableView makeViewWithIdentifier:strIdt owner:self];
    if (!aView)
        aView = [[NSTableCellView alloc] initWithFrame:CGRectMake(0, 0, tableColumn.width, rowH)];
    else
        for (NSView *view in aView.subviews)[view removeFromSuperview];
    
    IMBDevicePageFolderModel *model = [_dataArray objectAtIndex:row];
    NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, labelY, tableColumn.width, rowH - 2*labelY)];
    if (model) {
        if ([tableColumn.identifier isEqualToString:@"Name"]) {
            textField.stringValue = model.name;
        }else if ([tableColumn.identifier isEqualToString:@"Time"]) {
            double size = model.size/1024.0/1024.0;
            NSString *sizeStr = @"";
            if (size >= 1000) {
                size /= 1024.0;
                sizeStr = [NSString stringWithFormat:@"%.2f GB",size];
            }else {
                sizeStr = [NSString stringWithFormat:@"%.2f MB",size];
            }
            textField.stringValue = sizeStr;
        }else if ([tableColumn.identifier isEqualToString:@"Size"]) {
            double size = model.size/1024.0/1024.0;
            NSString *sizeStr = @"";
            if (size >= 1000) {
                size /= 1024.0;
                sizeStr = [NSString stringWithFormat:@"%.2f GB",size];
            }else {
                sizeStr = [NSString stringWithFormat:@"%.2f MB",size];
            }
            textField.stringValue = sizeStr;
        }else if ([tableColumn.identifier isEqualToString:@"Counts"]) {
            textField.stringValue = [NSString stringWithFormat:@"%lu",model.counts];
        }
        
    }
    
    textField.font = [NSFont systemFontOfSize:12.0f];
    textField.alignment = NSCenterTextAlignment;
    textField.drawsBackground = NO;
    textField.bordered = NO;
    textField.focusRingType = NSFocusRingTypeNone;
    textField.editable = NO;
    [aView addSubview:textField];
    return aView;
}



@end
