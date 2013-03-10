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
#import "IKImageFlowView.h"
#import "GBVImageFlowView.h"
#import "GBVViewerWindowController.h"
#import "GBVSaverConfigWindowController.h"
#import <Sparkle/Sparkle.h>
@interface GBVAppDelegate : NSObject <NSApplicationDelegate,NSXMLParserDelegate,NSAlertDelegate,GBVImageFlowViewDelegate> {
    NSMutableArray *images;
    GBVImage * curLoadingImage;
    NSInteger currentPid;
    bool isInSearch;
    bool hasMoreCell;
    NSInteger totalPosts;
    NSString * curSearchRequest;
    NSButton *cvFlow;
    NSView *primaryView;
    NSTimer * reloadTimer;
    GBVImageFlowView *cflow;
    NSMenuItem *useCFlow;
    NSToolbar *toolbar;
    NSMenuItem *isWhiteFlow;
    NSMenuItem *isDarkFlow;
}
- (IBAction)installSaver:(id)sender;
- (IBAction)configSaver:(id)sender;
@property (assign) IBOutlet NSToolbar *toolbar;
- (IBAction)whitifyFlow:(id)sender;
- (IBAction)statist:(id)sender;
- (IBAction)darkenFlow:(id)sender;
@property (assign) IBOutlet NSMenuItem *isWhiteFlow;
@property (assign) IBOutlet NSMenuItem *isDarkFlow;
- (IBAction)copySelectedItem:(id)sender;
- (IBAction)toBrowser:(id)sender;
- (IBAction)downIt:(id)sender;

@property (assign) IBOutlet NSMenuItem *useCFlow;
@property (assign) IBOutlet NSView *primaryView;
- (IBAction)cFlowToggle:(id)sender;
@property (assign) IBOutlet GBVImageFlowView *cflow;
@property (assign) NSTimer * reloadTimer;
@property (assign) IBOutlet NSTextField *loadText;
@property (assign) IBOutlet NSProgressIndicator *loadProgress;
@property (assign) IBOutlet NSPanel *loadPanel;
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
@property NSInteger totalPosts;
@property (assign) NSString * curSearchRequest;
- (IBAction)openMenuClick:(id)sender;
- (IBAction)didScale:(id)sender;
@property NSInteger currentPid;
@end
