//
//  GBVImage.h
//  GelbooruViewer
//
//  Created by Vladislav Korotnev on 1/18/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import <Foundation/Foundation.h>

#define THMODE_THUMB 0
#define THMODE_SAMP 1
@protocol GBVImageDownloadDelegate;
@interface GBVImage : NSObject <NSURLDownloadDelegate>


{
    int ver;
    bool hasAlreadyReqThumb;
    bool hasAlreadyReqSamp;
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
}

- (NSImage *)getBestAvailImage;
- (void) copyToPasteBoard;
- (void) performDownload;
-(void)browse;
- (NSImage *)getSampleImage;
@property (retain) NSURL *fullurl;
@property (retain)NSURL *sampleUrl;
@property (retain)NSURL *thumbUrl;
@property (retain)NSArray * tags;
@property  bool isMoreCell;
@property NSInteger idx;
@property (retain)NSString * webUrl;
-(void)requestSampleImageIntoCache;
@property (retain)NSString * rating;
@property (retain)id<GBVImageDownloadDelegate>downloadDelegate;
@property (retain) NSImage * cachedThumb;
@property (retain) NSImage * cachedSample;

- (GBVImage *)initWithFull: (NSURL*)full sample:(NSURL*)sample thumb:(NSURL*)thumb  rating:(NSString*)ratng tags:(NSArray*)t idx:(NSInteger)ind webUrl:(NSString *)web;
- (GBVImage *)initAsMoreCell ;
@end

@protocol GBVImageDownloadDelegate <NSObject>

- (void)_removeDownloadingProcessView;

@end
