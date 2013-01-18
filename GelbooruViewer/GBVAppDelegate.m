//
//  GBVAppDelegate.m
//  GelbooruViewer
//
//  Created by Vladislav Korotnev on 1/18/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import "GBVAppDelegate.h"

#define RATING_EXPLICIT @"e"
#define RATING_QUESTION @"q"
#define RATING_SAFE @"s"
#import "NSApplication+GBV.h"

@implementation GBVAppDelegate
@synthesize images,curLoadingImage,currentPid,curSearchRequest,isInSearch,totalPosts;

- (void) _progViewVisible: (bool)visible {
   if (visible) {
        [self.loadProgress startAnimation:self];
        
        [[NSApplication sharedApplication] beginSheet:self.loadPanel
                                       modalForWindow:self.window
                                        modalDelegate:self
                                       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
                                          contextInfo:nil];
    } else {
        [[NSApplication sharedApplication] stopModal];
        [self.loadPanel orderOut:self];
        [ NSApp endSheet:self.loadPanel returnCode:0 ] ;
    }
  
}
- (void) sheetDidEnd:(NSWindow *) sheet returnCode:(int)returnCode contextInfo:(void *) contextInfo {
   //stub
}

- (void) loadPics {
 
   

     
    self.currentPid = 0;
    [self.imageGrid setSelectionIndexes:nil byExtendingSelection:false];
    for (GBVImage * i in self.images) {
        [i release];
    }
    [self.images removeAllObjects];
    NSString * url = [NSString stringWithFormat:@"http://%@//index.php?page=dapi&s=post&q=index&pid=%li",[self.boardSelector selectedItem].title,self.currentPid ];
    if(isInSearch) {
        self.loadText.stringValue = [NSString stringWithFormat:@"Searching for %@...",curSearchRequest];
        url = [NSString stringWithFormat:@"%@&tags=%@",url,curSearchRequest];
    }
    NSURL * t = [NSURL URLWithString:[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   
    [self parseDocumentWithURL:t];
}



- (void) loadMorePics {
   
    [self.imageGrid setSelectionIndexes:nil byExtendingSelection:false];
    [self.images removeLastObject];
    self.currentPid = self.currentPid + 1;
    if (self.currentPid * 100 >= self.totalPosts) {
        NSLog(@"End!");
        return;
    }
    NSString * url = [NSString stringWithFormat:@"http://%@//index.php?page=dapi&s=post&q=index&pid=%li",[self.boardSelector selectedItem].title,self.currentPid ];
    if(isInSearch) {
        
        url = [NSString stringWithFormat:@"%@&tags=%@",url,curSearchRequest];
    }
    
   
    [self parseDocumentWithURL:[NSURL URLWithString:[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

}

- (void) _reloadList {
    [self _progViewVisible:false];
    [self.searchField setEnabled:true];
    [self.imageGrid reloadData];
    if (self.isInSearch) {
        self.window.title = [NSString stringWithFormat:@"GBBrowser Mac — %@ — %li of %li",self.curSearchRequest,hasMoreCell ? self.images.count - 1 : self.images.count,totalPosts];
    } else {
        self.window.title = [NSString stringWithFormat:@"GBBrowser Mac — %li of %li",hasMoreCell ? self.images.count - 1 : self.images.count,totalPosts];
    }
}
-(BOOL)parseDocumentWithURL:(NSURL *)url {
    if (url == nil)
        return NO;
    
    // this is the parsing machine
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    
    // this class will handle the events
    [xmlparser setDelegate:self];
    [xmlparser setShouldResolveExternalEntities:NO];
    
    // now parse the document
    BOOL ok = [xmlparser parse];
    if (ok == NO)
        NSLog(@"Error");
    else
        NSLog(@"OK");
    
    [xmlparser release];
    return ok;
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"Start");
    [self.searchField setEnabled:false];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"End");
    if (totalPosts > self.images.count+1) {
        [self.images addObject:[[GBVImage alloc]initAsMoreCell]];
        hasMoreCell = true;
    }
    for (GBVImage * i in images) {
        NSLog(@"Prefetch %li",i.idx);
        [i performSelectorInBackground:@selector(myThumbImageSingleThread) withObject:nil];
    }
    
    [self performSelectorOnMainThread:@selector(_reloadList) withObject:nil waitUntilDone:false];
    
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"post"]) {
       
        // print all attributes for this element
        NSEnumerator *attribs = [attributeDict keyEnumerator];
        NSString *key, *value;
        NSURL * thumb, *sample, *full;
        NSArray * tags;
        NSString  *rating,*ident;
        
        while((key = [attribs nextObject]) != nil) {
            value = [attributeDict objectForKey:key];
            if ([key isEqualToString:@"file_url"]) {
                full = [NSURL URLWithString:value];
            }
            if ([key isEqualToString:@"sample_url"]) {
                sample = [NSURL URLWithString:value];
            }
            if ([key isEqualToString:@"preview_url"]) {
                thumb = [NSURL URLWithString:value];
            }
            if ([key isEqualToString:@"rating"]) {
                rating = value;
            }
            if ([key isEqualToString:@"id"]) {
                ident = value;
            }
            if ([key isEqualToString:@"tags"]) {
                tags = [value componentsSeparatedByString:@" "];
            }
        }
        GBVImage* i = [[GBVImage alloc]initWithFull:full sample:sample thumb:thumb rating:rating tags:tags idx:self.images.count webUrl:[NSString stringWithFormat:@"http://%@//index.php?page=post&s=view&id=%@",self.boardSelector.selectedItem.title,ident]];
       
        [self.images addObject:i];
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
    NSAlert* msgBox = [[[NSAlert alloc] init] autorelease];
    [msgBox setMessageText: [NSString stringWithFormat:@"XMLParser error: %@", [parseError localizedDescription]]];
    [msgBox addButtonWithTitle: @"OK"];
    [msgBox runModal];
     
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    NSAlert* msgBox = [[[NSAlert alloc] init] autorelease];
    [msgBox setMessageText: [NSString stringWithFormat:@"XMLParser error: %@", [validationError localizedDescription]]];
    [msgBox addButtonWithTitle: @"OK"];
    [msgBox runModal];
}

- (void)dealloc
{
    [super dealloc];

}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults]synchronize];
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"agreed"]) {
        NSAlert* msgBox = [[[NSAlert alloc] init] autorelease];
        [msgBox setDelegate:self];
        [msgBox setMessageText:@"Warning"];
        [msgBox setInformativeText: @"This app is not recommended for users less than 16 years old! Are you 16 or older?"];
        [msgBox addButtonWithTitle: @"Yes"];
         [msgBox addButtonWithTitle: @"No"];
        NSInteger rCode = [msgBox runModal];
        if (rCode == NSAlertFirstButtonReturn) {
            [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"agreed"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [[NSApplication sharedApplication]terminate:self];
        } else if (rCode == NSAlertSecondButtonReturn) {
            [[NSApplication sharedApplication] terminate:self];
        } 
    } else {
        [self.scroller setDocumentView:self.imageGrid];
        [self.scroller setHasHorizontalRuler:false];
        [self.scroller setHasHorizontalScroller:false];
        [self.scroller setHasVerticalRuler:true];
        [self.scroller setHasVerticalScroller:true];
        [self.imageGrid setDataSource:self];
        [self.imageGrid setDelegate:self];
        self.images = [NSMutableArray new];
        NSString * curBoard = [[NSUserDefaults standardUserDefaults]objectForKey:@"board"];
        if ([curBoard isEqualToString:@""] || curBoard == nil) {
            NSLog(@"No board");
            curBoard = @"safebooru.org";
            [[NSUserDefaults standardUserDefaults]setObject:curBoard  forKey:@"board"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        [self.boardSelector selectItemWithTitle:curBoard];
        
        [self.scaler setFloatValue:[[NSUserDefaults standardUserDefaults]floatForKey:@"scale"]] ;
        [self.imageGrid setZoomValue:self.scaler.floatValue];
        [self.modSelector setSelectedSegment:[[NSUserDefaults standardUserDefaults]integerForKey:@"thMode"]];
        self.loadText.stringValue = @"Loading posts...";
        [self _progViewVisible:true];
        [self performSelectorInBackground:@selector(loadPics) withObject:nil];
    }
    // Insert code here to initialize your application
}

#pragma mark - IKImageBrowserDataSource

// -------------------------------------------------------------------------------
//	numberOfItemsInImageBrowser:view:
//
// Implement image-browser's datasource protocol.
// Our datasource representation is a simple mutable array.
// -------------------------------------------------------------------------------
- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)view
{
	return [images count];
}

// -------------------------------------------------------------------------------
//	imageBrowser:itemAtIndex:index
// -------------------------------------------------------------------------------
- (id)imageBrowser:(IKImageBrowserView *)view itemAtIndex:(NSUInteger)index
{
	return [images objectAtIndex:index];
}


#pragma mark - optional datasource methods


- (BOOL)imageBrowser:(IKImageBrowserView *)aBrowser moveItemsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)destinationIndex
{

	return NO;
}


#pragma mark - IKImageBrowserDelegate
- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasDoubleClickedAtIndex:(NSUInteger)index
{
    // get the image object
    if (index > self.images.count - 1) {
        NSLog(@"WTF");
        return;
    }
    GBVImage *imageObject = (GBVImage *)[images objectAtIndex:index];
    NSLog(@"Idx %li",index);
    if (imageObject)
    {
        
            if (imageObject.isMoreCell) {
                self.window.title = @"GBBrowser Mac — Loading..." ;
                self.loadText.stringValue = @"Loading more...";
                if(isInSearch)
                    self.loadText.stringValue = [NSString stringWithFormat:@"Searching more for %@...",curSearchRequest];
                [self _progViewVisible:true];
                [self performSelectorInBackground:@selector(loadMorePics) withObject:nil];
    
                return;
            }
        NSLog(@"Should vw");
        [self performSelectorInBackground:@selector(_popupViewerFor:) withObject:imageObject];
       // [v showWindow:self];
    }
}
- (void) _popupViewerFor:(GBVImage*)img {
    GBVViewerWindowController * v = [[GBVViewerWindowController alloc]initWithGBImage:img picArray:self.images];
}
- (IBAction)reloadStuff:(id)sender {
    
    [self performSelectorInBackground:@selector(loadPics) withObject:nil];
}
- (IBAction)doSearch:(id)sender {
    NSLog(@"Search");
    if([self.searchField.stringValue isEqualToString:@""]){
        isInSearch = false;
        self.window.title = @"GBBrowser Mac — Loading..." ;
        
        self.loadText.stringValue = @"Going back from search...";
        [self _progViewVisible:true];
        [self  performSelectorInBackground:@selector(loadPics) withObject:nil];
    } else {
    
        isInSearch = true;
        [self setCurSearchRequest:[self.searchField.stringValue stringByReplacingOccurrencesOfString:@" " withString:@"_"]] ;
        [self.curSearchRequest retain];
        self.window.title = @"GBBrowser Mac — Loading..." ;
        
        self.loadText.stringValue = [NSString stringWithFormat:@"Searching for %@...",curSearchRequest];
        [self _progViewVisible:true];
        [self  performSelectorInBackground:@selector(loadPics) withObject:nil];
    }
    
}
- (IBAction)boardSelection:(id)sender {
    self.window.title = @"GBBrowser Mac — Loading..." ;
    
    self.loadText.stringValue = @"Switching board...";
    [self _progViewVisible:true];
    for (NSWindow* w  in [[NSApplication sharedApplication]windows]) {
        if([w.title hasPrefix:@"Viewer"] || [w.title hasPrefix:@"Loading better"])
            [w close];
    }
    [[NSUserDefaults standardUserDefaults]setObject:self.boardSelector.selectedItem.title   forKey:@"board"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    isInSearch = false;
    [self.searchField setStringValue:@""];
    [self performSelectorInBackground:@selector(loadPics) withObject:nil];
}
- (IBAction)didScale:(NSSlider*)sender {
    [[NSUserDefaults standardUserDefaults]setFloat:sender.floatValue forKey:@"scale"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self.imageGrid setZoomValue:sender.floatValue];
    [self.imageGrid reloadData];
}

@end
