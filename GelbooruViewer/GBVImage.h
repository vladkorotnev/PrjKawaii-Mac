//
//  GBVImage.h
//  GelbooruViewer
//
//  Created by Vladislav Korotnev on 1/18/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#define THMODE_THUMB 0
#define THMODE_SAMP 1
@interface GBVImage : NSObject 


{
    int ver;
    NSURL *fullurl;
    NSURL *sampleUrl;
    NSURL *thumbUrl;
    NSArray * tags;
    bool isMoreCell;
    NSString * rating;
    NSImage * cachedThumb;
    NSImage * cachedSample;
    NSInteger * idx;
    NSString * webUrl;
    IKImageBrowserView *parent;
}
- (NSImage *)myThumbImage;
- (NSImage *)getSampleImage;
- (NSImage *)myThumbImageSingleThread ;
@property (retain) NSURL *fullurl;
@property (retain)NSURL *sampleUrl;
@property (retain)NSURL *thumbUrl;
@property (retain)NSArray * tags;
@property  bool isMoreCell;
@property NSInteger idx;
@property (retain)NSString * webUrl;

@property (retain)NSString * rating;
@property (retain) NSImage * cachedThumb;
@property (retain) NSImage * cachedSample;
@property (assign)IKImageBrowserView * parent;
- (GBVImage *)initWithFull: (NSURL*)full sample:(NSURL*)sample thumb:(NSURL*)thumb  rating:(NSString*)ratng tags:(NSArray*)t idx:(NSInteger)ind webUrl:(NSString *)web;
- (GBVImage *)initAsMoreCell ;
@end
