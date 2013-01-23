//
//  BooruSaverView.m
//  BooruSaver
//
//  Created by Vladislav Korotnev on 1/22/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import "BooruSaverView.h"

@implementation BooruSaverView

- (void) loadPics {
    NSString * url = [NSString stringWithFormat:@"http://%@//index.php?page=dapi&s=post&q=index&pid=%i",board,curPage ];
    if(![[tags stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]]isEqualToString:@""]) {
        url = [NSString stringWithFormat:@"%@&tags=-comic+-translation_request+%@",url,[tags stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
    }
    NSURL * t = [NSURL URLWithString:[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [self parseDocumentWithURL:t];
}


-(BOOL)parseDocumentWithURL:(NSURL *)url {
    if (url == nil)
    {NSLog(@"Nil url");
        return NO;}
    
    // this is the parsing machine
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    
    // this class will handle the events
    [xmlparser setDelegate:self];
    [xmlparser setShouldResolveExternalEntities:NO];

    // now parse the document
    BOOL ok = [xmlparser parse];
    
    
    return ok;
}


-(void)parserDidStartDocument:(NSXMLParser *)parser {
    if (!preloadIsBackground) {
        [self setAnimationTimeInterval:200];
        [self stopAnimation];
    }

}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    [self performSelectorInBackground:@selector(_precacheFrames) withObject:nil];
    if (!preloadIsBackground) {
            [self setAnimationTimeInterval:interval];
            [self startAnimation];
    }
}
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"post"]) {
        
        // print all attributes for this element
        NSEnumerator *attribs = [attributeDict keyEnumerator];
        NSString *key, *value;
        NSURL  *sample, *full;
        NSArray * mtags;
        
        while((key = [attribs nextObject]) != nil) {
            value = [attributeDict objectForKey:key];
            if ([key isEqualToString:@"file_url"]) {
                full = [NSURL URLWithString:value];
            }
            if ([key isEqualToString:@"sample_url"]) {
                sample = [NSURL URLWithString:value];
            }
        
            if ([key isEqualToString:@"tags"]) {
                mtags = [value componentsSeparatedByString:@" "];
            }
        }
        if(preventAbsurd>0){
            [pictures addObject:sample];
        } else {
            [pictures addObject:full];
        }
        [pictures retain];
        
    }
    if ([elementName isEqualToString:@"posts"]) {
        NSEnumerator *attribs = [attributeDict keyEnumerator];
        NSString *key, *value;
        
        while((key = [attribs nextObject]) != nil) {
            value = [attributeDict objectForKey:key];
            if ([key isEqualToString:@"count"]) {
                totalPosts = [value integerValue];
            }
        }
        
    }

}



-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
}


// error handling
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {

    
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {

}
-(void)_cacheFrame:(NSURL*)url{
    [precachedImages setObject: [[NSImage alloc]initWithContentsOfURL:url] forKey:[url lastPathComponent]];
    [precachedImages retain];
    NSLog(@"Made cache for %@",[url lastPathComponent]);
}
-(void)_precacheFrames {
    int precacheCount=0;
    int totalCount=0;
    for (NSURL*url in pictures) {
        totalCount++;
        if(![precachedImages objectForKey:[url lastPathComponent]]) {
            precacheCount++;
            [self performSelectorInBackground:@selector(_cacheFrame:) withObject:url];
        }
    }
    NSLog(@"Successfully made caches for %i of %i",precacheCount,totalCount);
}



- (void)initialization:(NSRect)frame{
    if(previewing)return;
    NSDictionary *conf = [NSDictionary dictionaryWithContentsOfFile:[@"~/Library/Preferences/com.vladkorotnev.boorusaver.plist" stringByExpandingTildeInPath]];
    if(![[NSFileManager defaultManager]fileExistsAtPath:[@"~/Library/Preferences/com.vladkorotnev.boorusaver.plist" stringByExpandingTildeInPath]])
        conf = @{@"board" : @"safebooru.com",@"tags":@"",@"absurd":@"1",@"delay":@"4"};
    
    interval = [[conf objectForKey:@"delay"]integerValue];
    preventAbsurd = [[conf objectForKey:@"absurd"]integerValue];
    curPage=0;
    curPic = 0;
    board = [conf objectForKey:@"board"];
    [board retain];
    tags = [conf objectForKey:@"tags"];
    [tags retain];
    currentImageView = [[NSImageView alloc]initWithFrame:frame];
    [currentImageView setImageScaling:NSImageScaleProportionallyUpOrDown];
    [currentImageView retain];
    pictures = [NSMutableArray new];
    [pictures retain];
    precachedImages = [NSMutableDictionary new];
    [precachedImages retain];
    [self addSubview:currentImageView];
    preloadIsBackground = false;
    [self loadPics];


}
- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
   
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
               
        
        previewing = isPreview;
        [self initialization:frame];
        
    }

    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{

    [super drawRect:rect];
}

-(NSImage*)getImageForIndex:(NSUInteger)idx{
    NSURL*url = [pictures objectAtIndex:idx];
    NSImage * attempt = [precachedImages objectForKey:[url lastPathComponent]];
        return attempt;
}

- (void)animateOneFrame
{
    if(previewing)return;
    curPic++;
    if((curPic + 10) == pictures.count) {
        preloadIsBackground= true;
        [self performSelectorInBackground:@selector(loadPics) withObject:nil];
    }
    if ((curPage * 100 >= totalPosts)&&curPic==(pictures.count-1))
        curPic = 0;
        
    [currentImageView.image release];
   
    [currentImageView setImage:[self getImageForIndex:curPic]];
    
}

- (BOOL)hasConfigureSheet
{

    return NO;
}

- (NSWindow*)configureSheet
{
    
    return nil;
}

@end
