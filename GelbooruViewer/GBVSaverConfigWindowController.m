//
//  GBVSaverConfigWindowController.m
//  GelbooruViewer
//
//  Created by Vladislav Korotnev on 1/22/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import "GBVSaverConfigWindowController.h"

@interface GBVSaverConfigWindowController ()

@end

@implementation GBVSaverConfigWindowController
@synthesize random;
@synthesize delayDisplay;
@synthesize absurdprevent;
@synthesize delaySlide;
@synthesize boardField;
@synthesize tagField;


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
- (void)showWindow:(id)sender   {
    [self initWithWindowNibName:@"GBVSaverConfigWindowController"];
    [super showWindow:self];
}
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSDictionary *conf = [NSDictionary dictionaryWithContentsOfFile:[@"~/Library/Preferences/com.vladkorotnev.boorusaver.plist" stringByExpandingTildeInPath]];
    if(![[NSFileManager defaultManager]fileExistsAtPath:[@"~/Library/Preferences/com.vladkorotnev.boorusaver.plist" stringByExpandingTildeInPath]])
        conf = @{@"board" : @"safebooru.com",@"tags":@"",@"absurd":@"1",@"delay":@"4",@"random":@"1"};
    
    [self.boardField selectItemWithTitle:[conf objectForKey:@"board"]];
    [self.tagField setStringValue:[conf objectForKey:@"tags"]];
    [self.delaySlide setIntegerValue:[[conf objectForKey:@"delay"]integerValue]];
    self.delayDisplay.stringValue = [NSString stringWithFormat:@"%li sec",self.delaySlide.integerValue];
    [self.absurdprevent setState:[[conf objectForKey:@"absurd"]integerValue]];
     [self.random setState:[[conf objectForKey:@"random"]integerValue]];
}
-(void)_writeConfig{
    NSMutableDictionary *conf = [NSMutableDictionary new];
    [conf setObject:self.boardField.selectedItem.title forKey:@"board"];
    [conf setObject:self.tagField.stringValue forKey:@"tags"];
     [conf setObject:[NSString stringWithFormat:@"%li",self.random.state] forKey:@"random"];
    [conf setObject:[NSString stringWithFormat:@"%li",self.absurdprevent.state] forKey:@"absurd"];
    [conf setObject:[NSString stringWithFormat:@"%li",self.delaySlide.integerValue] forKey:@"delay"];
    [conf writeToFile:[@"~/Library/Preferences/com.vladkorotnev.boorusaver.plist" stringByExpandingTildeInPath] atomically:false];
}

- (IBAction)boardChange:(id)sender {
    [self _writeConfig];
    
}

- (IBAction)tagChange:(id)sender {
   [self _writeConfig];
}
- (IBAction)delayChg:(id)sender {
    self.delayDisplay.stringValue = [NSString stringWithFormat:@"%li sec",self.delaySlide.integerValue];
      [self _writeConfig];
}
- (IBAction)absurdchange:(id)sender {
      [self _writeConfig];
}
- (IBAction)randomChange:(id)sender {
    [self _writeConfig];
}
@end
