//
//  GBVImage.m
//  GelbooruViewer
//
//  Created by Vladislav Korotnev on 1/18/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import "GBVImage.h"

@implementation GBVImage


@synthesize fullurl,sampleUrl,thumbUrl,tags,rating,cachedThumb,isMoreCell,parent,cachedSample,webUrl;

- (GBVImage *)initAsMoreCell {
    [self init];
    self.isMoreCell = true;
    self.thumbUrl = [[NSBundle mainBundle]URLForResource:@"more" withExtension:@"png"];
    self.sampleUrl = self.thumbUrl;
    return self;
}

- (GBVImage *)initWithFull: (NSURL*)full sample:(NSURL*)sample thumb:(NSURL*)thumb  rating:(NSString*)ratng tags:(NSArray*)t idx:(NSInteger)ind webUrl:(NSString *)web {
    [self init];
    if (self) {
        self.fullurl = full;
        self.sampleUrl =sample;
        self.thumbUrl = thumb;
        self.idx = ind;
        self.webUrl = web;
        self.rating = ratng;
        self.tags = [[NSArray alloc]initWithArray:t];
    }
    return  self;
}
- (void) _cacheThumb {
 
        cachedThumb = [[NSImage alloc]initWithContentsOfURL:self.thumbUrl];
   
  
  
    [cachedThumb retain];
 
}

- (NSImage *)myThumbImage {
    if (cachedSample != nil)
        return cachedSample;
    if (cachedThumb == nil) {
        [self performSelectorInBackground:@selector(_cacheThumb) withObject:nil];
        //[self _cacheThumb];
    }
    return cachedThumb;
}
- (NSImage *)myThumbImageSingleThread {
    if (cachedSample != nil)
        return cachedSample;
    if (cachedThumb == nil) {

        [self _cacheThumb];
    }
 
    return cachedThumb;
}
- (NSImage *)getSampleImage {
    if (cachedSample == nil) {
        cachedSample = [[NSImage alloc]initWithContentsOfURL:self.sampleUrl];
        [cachedSample retain];
    }
    return cachedSample;
}
#pragma mark - Item data source protocol

- (NSString *)imageRepresentationType
{
	return IKImageBrowserNSImageRepresentationType;
}

- (id)imageRepresentation
{
	return [self myThumbImage];
}

- (NSString *)imageUID
{
	return [NSString stringWithFormat:@"%p", self];
}

- (id)imageTitle
{
	return @"";
}


@end

