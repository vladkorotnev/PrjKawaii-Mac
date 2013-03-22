//
//  BooruSaverView.m
//  BooruSaver
//
//  Created by Vladislav Korotnev on 1/22/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import "BooruSaverView.h"

@implementation BooruSaverView
static NSTextField*status=nil;
static NSString* lastStat=@"";
static int alreadyCachedImages=0;
static int prevTrans=0;
static NSProgressIndicator*progr=nil;

- (void)setStat:(NSString*)s{
    lastStat=s;
    [status setHidden:[lastStat isEqualToString:@""]];
    [status setStringValue:lastStat];
    [status retain];
}
- (void) loadPics {
    NSString * url = [NSString stringWithFormat:@"http://%@//index.php?page=dapi&s=post&q=index&pid=%i",board,curPage ];
    if(![[tags stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]]isEqualToString:@""]) {
        url = [NSString stringWithFormat:@"%@&tags=-4koma+-comic+-translation_request+%@",url,[tags stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
    }
    NSURL * t = [NSURL URLWithString:[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //[self setStat:[NSString stringWithFormat:@"%@ %@ page %i, total %i, image %i, precached %i",board,tags,curPage,totalPosts,curPic,alreadyCachedImages]];
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
    //[self setStat:[NSString stringWithFormat:@"Parsing started, %@ page %i, total %i, image %i, preloaded in array %li",board,curPage,totalPosts,curPic,pictures.count]];
}
- (void)_startshow {
    [progr setHidden:true];
}
- (void)_cacheAPic{
    
    if (alreadyCachedImages == 11) {
        [self performSelectorOnMainThread:@selector(_startshow) withObject:nil waitUntilDone:false];
    } if(alreadyCachedImages<11) {
       //[self setStat:[NSString stringWithFormat:@"%@ %@ page %i, total %i, image %i, precached %i, isRandom: %i",board,tags,curPage,totalPosts,curPic,alreadyCachedImages,randomized]];
       [progr setDoubleValue:alreadyCachedImages];
    [progr retain];
    }
    if (alreadyCachedImages < pictures.count) {
        if([precachedImages objectForKey:[[pictures objectAtIndex:alreadyCachedImages]lastPathComponent]]==nil)
            [precachedImages setObject:[[NSImage alloc]initWithContentsOfURL:[pictures objectAtIndex:alreadyCachedImages]] forKey:[[pictures objectAtIndex:alreadyCachedImages]lastPathComponent]];
        [precachedImages retain];
        alreadyCachedImages++;
        [self _cacheAPic]; //recursively
        return;
    } else {
        
    }
}
-(void)parserDidEndDocument:(NSXMLParser *)parser {
    if (!preloadIsBackground) {

    }
    if (!(totalPosts <= curPage*100)) {
        preloadIsBackground=true;
        curPage++;
        [self performSelectorInBackground:@selector(loadPics) withObject:nil];
    } else {
        [self performSelectorInBackground:@selector(_cacheAPic) withObject:nil];
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
    
    [status setStringValue:[NSString stringWithFormat:@"error %@",parseError.localizedDescription]];
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    
}




- (void)initialization:(NSRect)frame{
    status = [[NSTextField alloc]initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, frame.size.width, 30))];
    [status setTextColor:[NSColor whiteColor]];
    [status setAlignment:NSCenterTextAlignment];
    [status setBackgroundColor:[NSColor blackColor]];
    [status setBezeled:FALSE];
    [status setBordered:FALSE];
    [status setEditable:FALSE];
    [status setSelectable:FALSE];
    [status setAlphaValue:0.5];
    progr = [[NSProgressIndicator alloc]initWithFrame:NSRectFromCGRect(CGRectMake(20, 0, frame.size.width-40, 30))];
    [progr setStyle:NSProgressIndicatorBarStyle];
    [progr setIndeterminate:FALSE];
    [progr setMinValue:0];
    [progr setMaxValue:10];
    [progr setDoubleValue:0];
    [progr startAnimation:self];
    if(previewing){
        [status setStringValue:@"Please use the Preview button"];
        [status setAlphaValue:1.0];
        [self addSubview:status];
        [self stopAnimation];
        [self setAnimationTimeInterval:10000];
        return;
    }
    
    NSDictionary *conf = [NSDictionary dictionaryWithContentsOfFile:[@"~/Library/Preferences/com.vladkorotnev.boorusaver.plist" stringByExpandingTildeInPath]];
    if(![[NSFileManager defaultManager]fileExistsAtPath:[@"~/Library/Preferences/com.vladkorotnev.boorusaver.plist" stringByExpandingTildeInPath]])
        conf = @{@"board" : @"safebooru.com",@"tags":@"",@"absurd":@"1",@"delay":@"4",@"random":@"1"};
    
    interval = [[conf objectForKey:@"delay"]integerValue];
    preventAbsurd = [[conf objectForKey:@"absurd"]integerValue];
    randomized = [[conf objectForKey:@"random"]integerValue];
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
    
    //[self addSubview:status];
    alreadyShownPics = [NSMutableArray new];
    [alreadyShownPics retain];
    preloadIsBackground = false;
    //[self stopAnimation];
    [self setAnimationTimeInterval:interval];
    [self setStat:@""];

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
/*
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
}*/

-(NSImage*)getImageForIndex:(NSUInteger)idx{
    // [self stopAnimation];
    NSURL*url = [pictures objectAtIndex:idx];
    NSImage * attempt = nil;
    if ([precachedImages objectForKey:[url lastPathComponent]]) {
        attempt = [precachedImages objectForKey:[url lastPathComponent]];
    } else {
        attempt = [[NSImage alloc]initWithContentsOfURL:url];
        if (attempt != nil) {
            [precachedImages setObject:attempt forKey:[url lastPathComponent]];
        }
    }
    
    if (attempt == nil) {
        return [NSImage imageNamed:NSImageNameCaution];
    }
    [alreadyShownPics addObject:[NSString stringWithFormat:@"%i",(int)idx]];
    [alreadyShownPics retain];
    //  [self startAnimation];
    return attempt;
}

- (void)animateOneFrame
{
    if(previewing)return;
    if (randomized != 1)curPic++;
    else {
        if (alreadyCachedImages > 10) {
            int nwp = SSRandomIntBetween(0, alreadyCachedImages);
            while ([alreadyShownPics containsObject:[NSString stringWithFormat:@"%i",nwp]]) {
                nwp = SSRandomIntBetween(0, alreadyCachedImages);
            }
            curPic=nwp;
        }
    }
    if (curPic==0) {
        NSImageView*newImageView = [[NSImageView alloc]initWithFrame:self.frame];
        [newImageView setImageScaling:NSImageScaleProportionallyUpOrDown];
        NSImageView*oldImageView = currentImageView;
        [newImageView setImage:[self getImageForIndex:curPic]];
        NSArray*ani = @[@"fade",@"movein",@"push",@"reveal",@"CIBarsSwipeTransition",@"CIFlashTransition",@"CIModTransition"];
        int trans=SSRandomIntBetween(0, ani.count-1);
        while (trans == prevTrans) {
            trans=SSRandomIntBetween(0, ani.count-1);
        }
        prevTrans=trans;
        NSString* t=[ani objectAtIndex:trans];
        [self updateSubviewsWithTransition:t];
        [self replaceSubview:currentImageView with:newImageView];
        [self addSubview:progr];
        
        
        currentImageView = [newImageView retain];
        if (oldImageView.image) {
            NSImage*i = oldImageView.image;
            [i release];
        }
        
        [oldImageView release];
    }
    if (alreadyCachedImages >= 10) {
        NSArray*ani = @[@"fade",@"movein",@"push",@"reveal",@"CIBarsSwipeTransition",@"CIFlashTransition",@"CIModTransition"];
        int trans=SSRandomIntBetween(0, ani.count-1);
        while (trans == prevTrans) {
            trans=SSRandomIntBetween(0, ani.count-1);
        }
        prevTrans=trans;
        NSString* t=[ani objectAtIndex:trans];
        [self updateSubviewsWithTransition:t];
        NSImageView*newImageView = [[NSImageView alloc]initWithFrame:self.frame];
        [newImageView setImageScaling:NSImageScaleProportionallyUpOrDown];
        NSImageView*oldImageView = currentImageView;
        [newImageView setImage:[self getImageForIndex:curPic]];
        [self setWantsLayer:true];
        [[self animator]replaceSubview:currentImageView with:newImageView];
        [self setWantsLayer:true];
        currentImageView = [newImageView retain];
        [self performSelector:@selector(_purgeOldImageAfterAnimation:) withObject:oldImageView afterDelay:1.1];
    }

}
-(void)_purgeOldImageAfterAnimation:(NSImageView*)oldImageView{
    if (oldImageView.image) {
        NSImage*i = oldImageView.image;
        [i release];
    }
    
    [oldImageView release];
}

- (void)updateSubviewsWithTransition:(NSString *)transition
{
    NSRect		rect = [self bounds];
    CIFilter	*transitionFilter = nil;
   // [self setStat:transition];
    // Use Core Animation's four built-in CATransition types,
	// or an appropriately instantiated and configured Core Image CIFilter.
    //
    transitionFilter = [CIFilter filterWithName:transition];
    [transitionFilter setDefaults];
    
    if ([transition isEqualToString:@"CICopyMachineTransition"])
    {
        [transitionFilter setValue:
         [CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height]
                            forKey:@"inputExtent"];
    }
    else if ([transition isEqualToString:@"CIFlashTransition"])
    {
        [transitionFilter setValue:[CIVector vectorWithX:NSMidX(rect) Y:NSMidY(rect)] forKey:@"inputCenter"];
        [transitionFilter setValue:[CIVector vectorWithX:rect.origin.x Y:rect.origin.y Z:rect.size.width W:rect.size.height] forKey:@"inputExtent"];
    }
    else if ([transition isEqualToString:@"CIModTransition"])
    {
        [transitionFilter setValue:[CIVector vectorWithX:NSMidX(rect) Y:NSMidY(rect)] forKey:@"inputCenter"];
    }

    
    // construct a new CATransition that describes the transition effect we want.
	CATransition *newTransition = [CATransition animation];
    if (transitionFilter)
	{
        // we want to build a CIFilter-based CATransition.
		// When an CATransition's "filter" property is set, the CATransition's "type" and "subtype" properties are ignored,
		// so we don't need to bother setting them.
        [newTransition setFilter:transitionFilter];
    }
	else
	{

        [newTransition setType:transition];
        [newTransition setSubtype:[@[kCATransitionFromBottom,kCATransitionFromLeft,kCATransitionFromRight,kCATransitionFromTop]objectAtIndex:arc4random()%3]];
    }
    
    // specify an explicit duration for the transition.
    [newTransition setDuration:1];
    
    // associate the CATransition we've just built with the "subviews" key for this SlideshowView instance,
	// so that when we swap ImageView instances in our -transitionToImage: method below (via -replaceSubview:with:).
	 [self setWantsLayer:true];
	[self setAnimations:[NSDictionary dictionaryWithObject:newTransition forKey:@"subviews"]];
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
