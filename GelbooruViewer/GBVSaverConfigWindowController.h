//
//  GBVSaverConfigWindowController.h
//  GelbooruViewer
//
//  Created by Vladislav Korotnev on 1/22/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GBVSaverConfigWindowController : NSWindowController {
    NSSearchField *tagField;
    NSPopUpButton *boardField;

    NSSliderCell *delaySlide;
    NSTextField *delayDisplay;
    NSButton *absurdprevent;
}
@property (assign) IBOutlet NSPopUpButton *boardField;

@property (assign) IBOutlet NSSearchField *tagField;
- (IBAction)boardChange:(id)sender;
- (IBAction)tagChange:(id)sender;
@property (assign) IBOutlet NSSliderCell *delaySlide;
- (IBAction)delayChg:(id)sender;
@property (assign) IBOutlet NSTextField *delayDisplay;
@property (assign) IBOutlet NSButton *absurdprevent;
- (IBAction)absurdchange:(id)sender;

@end
