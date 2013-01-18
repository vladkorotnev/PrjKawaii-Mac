//
//  GBVViewerWindowController.m
//  GelbooruViewer
//
//  Created by Vladislav Korotnev on 1/18/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import "GBVViewerWindowController.h"

@interface GBVViewerWindowController ()

@end

@implementation GBVViewerWindowController
@synthesize image,picA;
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
    
    
}
- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return NO;
}
// just returns the item for the right row
- (id)     tableView:(NSTableView *) aTableView
objectValueForTableColumn:(NSTableColumn *) aTableColumn
                 row:(NSInteger ) rowIndex
{
       
    return [image.tags objectAtIndex:rowIndex];
}

// just returns the number of items we have.
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSLog(@"count");
    return [image.tags count];
}
- (void)_displayFullImage:(NSImage*)image {
    [self.PictureVw setImage:image];
    NSString * t = @"";
    for (NSString* tag in self.image.tags) {
        if (![tag isEqualToString:@""] && ![tag isEqualToString:@" "]) {
            if ([t isEqualToString:@""]) {
                t = [NSString stringWithFormat:@"Viewer — %@",tag];
            } else
                t = [NSString stringWithFormat:@"%@, %@",t,tag];
        }
    }
    self.window.title = t;
}
- (void) _loadFullImage {
    NSImage * i = [[image getSampleImage]autorelease];
    [self performSelectorOnMainThread:@selector(_displayFullImage:) withObject:i waitUntilDone:false];
   
}

- (IBAction)nextPic:(id)sender {
   self.window.title = @"Loading better image..." ;
        int temp = image.idx + 1;
        NSLog(@"ID %i",temp);
        if (temp <= picA.count-1) {
            [self.image release];
            self.image = nil;
            [self.PictureVw.image release];
            self.PictureVw.image = nil;
            self.image = [picA objectAtIndex:temp];
            [self.PictureVw setImage:[image myThumbImage]];
            [self performSelectorInBackground:@selector(_loadFullImage) withObject:nil];
            [self.tagTable reloadData];
            [self.btPref setEnabled:true];
            
        } else {
            [self.btNext setEnabled:false];
        }
}
- (IBAction)prevPic:(id)sender {
  self.window.title = @"Loading better image..." ;
        int temp = image.idx - 1;
        NSLog(@"ID %i",temp);
        if (temp < 0) {
            temp = 0;
            [self.btPref setEnabled:false];
        }
        if (temp >= 0) {
            [self.image release];
            self.image = nil;
            [self.PictureVw.image release];
            self.PictureVw.image = nil;
            self.image = [picA objectAtIndex:temp];
            [self.PictureVw setImage:[image myThumbImage]];
            [self performSelectorInBackground:@selector(_loadFullImage) withObject:nil];
            [self.tagTable reloadData];
            [self.btNext setEnabled:true];
        }

}


- (GBVViewerWindowController*)initWithGBImage:(GBVImage *) img picArray:(NSArray*)arr{
    [self initWithWindowNibName:@"GBVViewerWindowController"];
    if (self) {
        self.image = img;
        [self.image retain];
        picA = arr;
        [picA retain];
        [self showWindow:self];
 [self.PictureVw setImage:[image myThumbImage]];
        self.window.title = @"Loading better image..." ;
        [self performSelectorInBackground:@selector(_loadFullImage) withObject:nil];
        [self.tagTable setDelegate:self];
        [self.tagTable setDataSource:self];
        
        [self.tagTable setAllowsTypeSelect:NO];
        [self.tagTable setAllowsMultipleSelection:NO];
        [self.tagTable setAllowsEmptySelection:NO];
        [self.tagTable setAllowsColumnSelection:NO];
        [self.tagTable setAllowsColumnResizing:NO];
        [self.tagTable setAllowsColumnReordering:NO];
    }
    return self;
}

- (IBAction)goWeb:(id)sender {
[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:self.image.webUrl]];
}
- (IBAction)downloadThis:(id)sender {
    // Create the request.
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:self.image.fullurl
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:60.0];
    
    // Create the download with the request and start loading the data.
    NSURLDownload  *theDownload = [[NSURLDownload alloc] initWithRequest:theRequest delegate:self];
    if (!theDownload) {
        // Inform the user that the download failed.
    } 
}

- (IBAction)copyToboard:(id)sender {
    NSLog(@"COPY");
    NSPasteboard * board = [NSPasteboard generalPasteboard];
    [board clearContents];
    NSArray * itemsToCopy = [NSArray arrayWithObjects:[image getSampleImage], self.image.fullurl, nil];
    [board writeObjects:itemsToCopy];
}


- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
    NSString *destinationFilename;
    NSString *homeDirectory = NSHomeDirectory();
    
    destinationFilename = [[homeDirectory stringByAppendingPathComponent:@"Downloads"]
                           stringByAppendingPathComponent:filename];
    [download setDestination:destinationFilename allowOverwrite:NO];
}


- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    // Release the download.
    [download release];
    
    // Inform the user.
    NSLog(@"Download failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    // Release the download.
    [download release];
    
    // Do something with the data.
    NSLog(@"%@",@"downloadDidFinish");
}
@end
