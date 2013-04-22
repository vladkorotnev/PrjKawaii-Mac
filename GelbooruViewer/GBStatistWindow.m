//
//  GBStatistWindow.m
//  GelbooruViewer
//
//  Created by Vladislav Korotnev on 1/20/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import "GBStatistWindow.h"

@interface NSString (JRStringAdditions)

- (BOOL)containsString:(NSString *)string;
- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions) options;

@end

@implementation NSString (JRStringAdditions)

- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options {
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL)containsString:(NSString *)string {
    return [self containsString:string options:0];
}

@end

@implementation GBStatistWindow
@synthesize headLaberl;
@synthesize ResultTable;
@synthesize workerPanel;
@synthesize workerText;
@synthesize workerProgress;

@synthesize exclusionList;
@synthesize killExcluded;
@synthesize boardField;

@synthesize tagField;
- (void) _progViewVisible: (bool)visible {
    if (visible) {
        [self.workerProgress startAnimation:self];
        [spinner startAnimation:self];
        [[NSApplication sharedApplication] beginSheet:self.workerPanel
                                       modalForWindow:self.window
                                        modalDelegate:self
                                       didEndSelector:nil
                                          contextInfo:nil];
    } else {
        [[NSApplication sharedApplication] stopModal];
        [self.workerPanel orderOut:self];
        [ NSApp endSheet:self.workerPanel returnCode:0 ] ;
    }
    
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"board"]isEqualToString:@"xbooru.com"]) {
      [self.boardField selectItemWithTitle:[[NSUserDefaults standardUserDefaults]objectForKey:@"board"]];
    }
   
}


- (IBAction)beginAnalysis:(id)sender {
    
    if ([self.tagField.stringValue isEqualToString:@""])return;
    self.tagField.stringValue = [self.tagField.stringValue stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    [self.ResultTable setDelegate:nil];
    [self.ResultTable setDataSource:nil];
    if (tagCounts) {
        [tagCounts release];
        tagCounts = nil;
    }
    if (alltags) {
        [alltags release];
        alltags = nil;
    }
    tagCounts = [NSMutableDictionary new];
    currentProcessedPage = 0;
    totalPages = 1;
    totalImg = 0;
    alltags = @"";
    [alltags retain];
    [self _nextPage];
    [self _progViewVisible:true];
}

- (void) _completedLoading {
    [self _progViewVisible:false];
    self.headLaberl.stringValue = [NSString stringWithFormat:@"These are the most common within the found %i:",totalImg];
    [self.ResultTable setDataSource:self];
    [self.ResultTable setDelegate:self];
    
    [self.ResultTable reloadData];
}


- (void)_countStats {
    exclusionList.stringValue = [exclusionList.stringValue stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    if (killExcluded.state==1) {
        NSArray * exclusionSet = [exclusionList.stringValue componentsSeparatedByString:@"+"];
        for (NSString* key in exclusionSet) {
            if ([tagCounts objectForKey:key]) {
                [tagCounts removeObjectForKey:key];
                totalTags--;
            }
        }
    }
    for (NSString* key in [tagCounts allKeys]) {
        if (([[tagCounts objectForKey:key]integerValue] < (totalImg * 0.05)) || [key isEqualToString:@"tagme"] || [key isEqualToString:@""] || [key isEqualToString:@" "]) {
            [tagCounts removeObjectForKey:key];
            totalTags--;
        }
    }

    NSMutableArray*temp = [NSMutableArray new];
    for (NSString*a in [tagCounts allKeys]) {
        [temp addObject:[NSString stringWithFormat:@"%@/%@",a,[tagCounts objectForKey:a]]];
    }
   
   NSArray* temp2 = [temp sortedArrayWithOptions:nil usingComparator:^NSComparisonResult(id obj1, id obj2) {
       NSLog(@"Comparing %i %i", [[[obj1 componentsSeparatedByString:@"/"]objectAtIndex:1] intValue] ,[[[obj2 componentsSeparatedByString:@"/"]objectAtIndex:1] intValue]);
        if ([[[obj1 componentsSeparatedByString:@"/"]objectAtIndex:1] intValue] > [[[obj2 componentsSeparatedByString:@"/"]objectAtIndex:1] intValue]) {
            return NSOrderedAscending;
        }
        if ([[[obj1 componentsSeparatedByString:@"/"]objectAtIndex:1] intValue] < [[[obj2 componentsSeparatedByString:@"/"]objectAtIndex:1] intValue]) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
   }];
    sortedIndexes = [NSMutableArray new];
    [tagCounts removeAllObjects];
    for (NSString*itm in temp2) {
        [tagCounts setObject:[[itm componentsSeparatedByString:@"/"]objectAtIndex:1] forKey:[[itm componentsSeparatedByString:@"/"]objectAtIndex:0]];
        [tagCounts retain];
    }
    for (NSString*itm in temp2) {
        [sortedIndexes addObject:[NSString stringWithFormat:@"%li",[[tagCounts allKeys]indexOfObject:[[itm componentsSeparatedByString:@"/"]objectAtIndex:0]]]];
        [sortedIndexes retain];
    }
    
    [self performSelectorOnMainThread:@selector(_completedLoading) withObject:nil waitUntilDone:NO];
}
- (void)_nextPage {
    NSLog(@"Next page %i of %i",currentProcessedPage,totalPages );
    if (![alltags isEqualToString:@""]) {
       
        [alltags retain];
        
        for (NSString*substring in [alltags componentsSeparatedByString:@" "]) {
            if (![substring isEqualToString:self.tagField.stringValue ] && ![substring containsString:self.tagField.stringValue]) {
                int curTagC = [[tagCounts objectForKey:substring]intValue];
                curTagC++;
                
                [tagCounts setObject:[NSString stringWithFormat:@"%i",curTagC] forKey:substring];
                [tagCounts retain];
                totalTags++;
            }
        }
        [alltags release];
        alltags = nil;
        alltags = @"";
        [alltags retain];
    }
    if (totalPages >= currentProcessedPage) {
    
        NSString * url = ([self.boardField.selectedItem.title isEqualToString:@"yande.re"]? [NSString stringWithFormat:@"http://%@//post.xml?page=%i",self.boardField.selectedItem.title,currentProcessedPage+1 ] : [NSString stringWithFormat:@"http://%@//index.php?page=dapi&s=post&q=index&pid=%i",self.boardField.selectedItem.title,currentProcessedPage ]);
  
            
        url = [NSString stringWithFormat:@"%@&tags=%@",url,self.tagField.stringValue];
        
        NSURL * t = [NSURL URLWithString:[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if (currentProcessedPage == 0) 
             self.workerText.stringValue = @"Please wait...";
         else  self.workerText.stringValue = [NSString stringWithFormat:@"Fetching page %i of %i...",currentProcessedPage,totalPages];
        [self.workerProgress setIndeterminate:false];
        [self.workerProgress setMinValue:0];
        [self.workerProgress setMaxValue:totalPages];
        [self.workerProgress setDoubleValue:currentProcessedPage];
        
        [self performSelectorInBackground:@selector(parseDocumentWithURL:) withObject:t];
      
    } else {
        NSLog(@"Done all pages");
        self.workerText.stringValue = @"Making statistics...";
        [self.workerProgress setIndeterminate:true];
        [self performSelectorInBackground:@selector(_countStats) withObject:nil];
    }
}

-(BOOL)parseDocumentWithURL:(NSURL *)url {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
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
    
    [xmlparser release];
    [pool drain];
    return ok;
}


-(void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"Starting");
    
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    currentProcessedPage++;
    [self performSelectorOnMainThread:@selector(_nextPage) withObject:nil waitUntilDone:NO];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"post"]) {
        
        // print all attributes for this element
        NSEnumerator *attribs = [attributeDict keyEnumerator];
        NSString *key,*value;
        totalImg++;
        while((key = [attribs nextObject]) != nil) {
            value = [attributeDict objectForKey:key];
            if ([key isEqualToString:@"tags"]) {
                alltags = [NSString stringWithFormat:@"%@%@",alltags,value];
               [alltags retain];
            }
        }
      
    }
    if ([elementName isEqualToString:@"posts"]) {
        NSEnumerator *attribs = [attributeDict keyEnumerator];
        NSString *key, *value;
        
        while((key = [attribs nextObject]) != nil) {
            value = [attributeDict objectForKey:key];
            if ([key isEqualToString:@"count"]) {
                totalPages = round([value doubleValue]/([self.boardField.selectedItem.title isEqualToString:@"yande.re"]?16:100));
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
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [tagCounts count];
}


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([[tableColumn.headerCell stringValue]isEqualTo:@"Tag"]) {
        return [[tagCounts allKeys]objectAtIndex:[[sortedIndexes objectAtIndex:row]intValue]];
    }
    if ([[tableColumn.headerCell stringValue]isEqualTo:@"Absolute"]) {
        return [tagCounts objectForKey:[[tagCounts allKeys]objectAtIndex:[[sortedIndexes objectAtIndex:row]intValue]]];
    }
    return @"wat.";
}


- (IBAction)saveToFile:(id)sender {
    NSSavePanel *save = [NSSavePanel savePanel];
    
    long int result = [save runModal];
    
    if (result == NSOKButton)
    {
        NSString *selectedFile = [save filename];
        NSString *fileName = [[NSString alloc] initWithFormat:@"%@.plist", selectedFile];
        [tagCounts writeToFile:fileName
                        atomically:NO];
    }
}
- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return NO;
}
@end
