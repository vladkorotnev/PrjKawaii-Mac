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
    NSLog(@"BS: Trying to load");
    curPage= 0;
    
    curPic=0;
    [pictures removeAllObjects];
    [pictures retain];
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
    NSLog(@"Starting parse");
    // now parse the document
    BOOL ok = [xmlparser parse];
    if (ok == NO)
        NSLog(@"Error");
    else
        NSLog(@"OK");
    
    
    return ok;
}


-(void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"Start");
  [self setAnimationTimeInterval:200];
    [self stopAnimation];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"End");
[self setAnimationTimeInterval:interval];
    [self startAnimation];
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
        if([mtags containsObject:@"absurdres"] && (preventAbsurd > 0))
            [pictures addObject:sample];
        else
            [pictures addObject:full];
        [pictures retain];
    }
}



-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
}


// error handling
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {

    
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {

}

- (void)initialization:(NSRect)frame{
    NSDictionary *conf = [NSDictionary dictionaryWithContentsOfFile:[@"~/Library/Preferences/com.vladkorotnev.boorusaver.plist" stringByExpandingTildeInPath]];
    if(![[NSFileManager defaultManager]fileExistsAtPath:[@"~/Library/Preferences/com.vladkorotnev.boorusaver.plist" stringByExpandingTildeInPath]])
        conf = @{@"board" : @"safebooru.com",@"tags":@"",@"absurd":@"1",@"delay":@"4"};
    
    interval = [[conf objectForKey:@"delay"]integerValue];
    preventAbsurd = [[conf objectForKey:@"absurd"]integerValue];
    curPage=0;
    board = [conf objectForKey:@"board"];
    [board retain];
    tags = [conf objectForKey:@"tags"];
    [tags retain];
    currentImageView = [[NSImageView alloc]initWithFrame:frame];
    [currentImageView setImageScaling:NSImageScaleProportionallyUpOrDown];
    [currentImageView retain];
    pictures = [NSMutableArray new];
    [pictures retain];
    [self addSubview:currentImageView];
    [self loadPics];
    NSLog(@"BS initer");

}
- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
   
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
                 NSLog(@"Boorusaver init");
        
        if(!isPreview)[self initialization:frame];
        
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

- (void)animateOneFrame
{
    curPic++;
    if (curPic >= pictures.count)
       curPic = 0;
    NSLog(@"BS animates");
    [currentImageView.image release];
   
    [currentImageView setImage:[[NSImage alloc]initWithContentsOfURL:[pictures objectAtIndex:curPic]]];
    
}

- (BOOL)hasConfigureSheet
{
    NSLog(@"BS confshit: no");
    return NO;
}

- (NSWindow*)configureSheet
{
    NSLog(@"BS confshit: no");
    return nil;
}

@end
