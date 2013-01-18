//
//  GBVAppDelegate.h
//  GelbooruViewer
//
//  Created by Vladislav Korotnev on 1/18/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "GBVImage.h"
#import "GBVViewerWindowController.h"
@interface GBVAppDelegate : NSObject <NSApplicationDelegate,NSXMLParserDelegate,NSAlertDelegate> {
    NSMutableArray *images;
    GBVImage * curLoadingImage;
    NSInteger currentPid;
    bool isInSearch;
    bool hasMoreCell;
    NSInteger totalPosts;
    NSString * curSearchRequest;
}
@property (assign) IBOutlet NSTextField *loadText;
@property (assign) IBOutlet NSProgressIndicator *loadProgress;
@property (assign) IBOutlet NSPanel *loadPanel;
@property (assign) IBOutlet NSPanel *errorWindow;
@property (assign) IBOutlet NSTextView *errorLog;
@property (assign) NSMutableArray *images;
@property (assign) IBOutlet NSSearchField *searchField;
- (IBAction)doSearch:(id)sender;
@property (assign) GBVImage * curLoadingImage;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet IKImageBrowserView *imageGrid;
- (IBAction)reloadStuff:(id)sender;
@property (assign) IBOutlet NSPopUpButton *boardSelector;
- (IBAction)boardSelection:(id)sender;
@property (assign) IBOutlet NSScrollView *scroller;
@property (assign) IBOutlet NSSlider *scaler;
@property bool isInSearch;
- (IBAction)modSel:(id)sender;
@property (assign) IBOutlet NSSegmentedControl *modSelector;
@property NSInteger totalPosts;
@property (assign) NSString * curSearchRequest;
- (IBAction)didScale:(id)sender;
@property NSInteger currentPid;
@end
