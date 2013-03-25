//
//  GBStatistWindow.h
//  GelbooruViewer
//
//  Created by Vladislav Korotnev on 1/20/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GBStatistWindow : NSWindowController<NSXMLParserDelegate,NSTableViewDataSource,NSTableViewDelegate> {
    NSSearchField *tagField;
    NSTableView *ResultTable;
    NSPanel *workerPanel;
    NSTextField *workerText;
    NSProgressIndicator *workerProgress;
    int totalPages;
    int currentProcessedPage;
    NSString * alltags;
    NSMutableDictionary * tagCounts;
    int totalTags;
    int totalImg;
    IBOutlet NSProgressIndicator *spinner;
    NSMutableArray *sortedIndexes;

    NSButton *killExcluded;
    NSPopUpButton *boardField;
    NSTextField *exclusionList;

    NSTextField *headLaberl;
}
@property (assign) IBOutlet NSTextField *headLaberl;

- (IBAction)saveToFile:(id)sender;
@property (assign) IBOutlet NSTextField *exclusionList;
@property (assign) IBOutlet NSButton *killExcluded;
@property (assign) IBOutlet NSPopUpButton *boardField;

@property (assign) IBOutlet NSSearchField *tagField;
- (IBAction)beginAnalysis:(id)sender;
@property (assign) IBOutlet NSTableView *ResultTable;
@property (assign) IBOutlet NSPanel *workerPanel;
@property (assign) IBOutlet NSTextField *workerText;
@property (assign) IBOutlet NSProgressIndicator *workerProgress;

@end
