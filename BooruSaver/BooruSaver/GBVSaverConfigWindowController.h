//
//  GBVSaverConfigWindowController.h
//  GelbooruViewer
//
//  Created by Vladislav Korotnev on 1/22/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GBVSaverConfigWindowControllerSV : NSWindowController {
    NSTextField *tagField;
    NSPopUpButton *boardField;

    IBOutlet NSButton *doneBtn;
    NSSliderCell *delaySlide;
    NSTextField *delayDisplay;
    NSButton *absurdprevent;
    NSButton *random;
    NSWindow *configWindow;
}
@property (assign) IBOutlet NSWindow *configWindow;
@property (assign) IBOutlet NSPopUpButton *boardField;
- (IBAction)doneAct:(id)sender;

@property (assign) IBOutlet NSTextField *tagField;
- (IBAction)boardChange:(id)sender;
- (IBAction)tagChange:(id)sender;
@property (assign) IBOutlet NSSliderCell *delaySlide;
- (IBAction)delayChg:(id)sender;
@property (assign) IBOutlet NSTextField *delayDisplay;
@property (assign) IBOutlet NSButton *absurdprevent;
- (IBAction)absurdchange:(id)sender;
@property (assign) IBOutlet NSButton *random;
- (IBAction)randomChange:(id)sender;
- (GBVSaverConfigWindowControllerSV*)initForShowingPrefs;
@end
