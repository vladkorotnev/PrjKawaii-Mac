//
//  NSApplication+GBV.m
//  GelbooruViewer
//
//  Created by Vladislav Korotnev on 1/18/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import "NSApplication+GBV.h"

@implementation NSApplication (GBV)
- (void)relaunchAfterDelay:(float)seconds
{
	NSTask *task = [[[NSTask alloc] init] autorelease];
	NSMutableArray *args = [NSMutableArray array];
	[args addObject:@"-c"];
	[args addObject:[NSString stringWithFormat:@"sleep %f; open \"%@\"", seconds, [[NSBundle mainBundle] bundlePath]]];
	[task setLaunchPath:@"/bin/sh"];
	[task setArguments:args];
	[task launch];
	
	[self terminate:nil];
}
@end
