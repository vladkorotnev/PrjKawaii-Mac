//
//  GBVViewerWindowController.h
//  GelbooruViewer
//
//  Created by Vladislav Korotnev on 1/18/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GBVImage.h"
@interface GBVViewerWindowController : NSWindowController<NSURLDownloadDelegate,NSTableViewDataSource,NSTableViewDelegate> {
    GBVImage * image;
    NSArray* picA;
}
@property (assign) IBOutlet NSImageView *PictureVw;
@property (assign) IBOutlet NSTableView *tagTable;
@property (assign)GBVImage * image;
@property (assign) NSArray*picA;

- (IBAction)downloadThis:(id)sender;
@property (assign) IBOutlet NSSegmentedControl *modeSelector;
- (IBAction)modechg:(id)sender;
- (IBAction)copyToboard:(id)sender;
@property (assign) IBOutlet NSToolbarItem *btPref;
@property (assign) IBOutlet NSToolbarItem *btCopy;
- (IBAction)ldFull:(id)sender;
- (GBVViewerWindowController*)initWithGBImage:(GBVImage *) img picArray:(NSArray*)arr;
- (IBAction)goWeb:(id)sender;
@property (assign) IBOutlet NSToolbarItem *btDl;
@property (assign) IBOutlet NSToolbarItem *btNext;
@end
