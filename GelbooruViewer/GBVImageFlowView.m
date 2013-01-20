//
//  GBVImageFlowView.m
//  GelbooruViewer
//
//  Created by Vladislav Korotnev on 1/18/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import "GBVImageFlowView.h"

@implementation GBVImageFlowView
@synthesize delegate;
- (void)keyDown:(NSEvent *)event
{
	[super keyDown:event];
	
	if([[event charactersIgnoringModifiers] characterAtIndex:0] == ' ')
		[self userDidPressSpaceInOutlineView:self];
	else if([[event charactersIgnoringModifiers] characterAtIndex:0] == NSRightArrowFunctionKey)
		[self userDidPressRightInView:self];
	else if([[event charactersIgnoringModifiers] characterAtIndex:0] == NSLeftArrowFunctionKey)
		[self userDidPressLeftInView:self];
	
}
- (void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
    if ([theEvent clickCount] == 2) {
        [self.delegate handleActivationOnIndex:self.selectedIndex];
    }
}
- (void)userDidPressSpaceInOutlineView:(id)anOutlineView
{
	NSLog(@"activate");
	[self.delegate handleActivationOnIndex:self.selectedIndex];
}

- (void)userDidPressRightInView:(id)anOutlineView
{
    NSLog(@"rigth");
}

- (void)userDidPressLeftInView:(id)anOutlineView
{
	NSLog(@"left");
}

@end
