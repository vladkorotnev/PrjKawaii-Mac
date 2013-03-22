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
    NSImage * i =[image getBestAvailImageForce];
    [self performSelectorOnMainThread:@selector(_displayFullImage:) withObject:i waitUntilDone:false];
   
}

- (IBAction)nextPic:(id)sender {
   self.window.title = @"Loading better image..." ;
        long temp = image.idx + 1;
        NSLog(@"ID %li",temp);
        if (temp <= picA.count-1) {
            [self.image release];
            self.image = nil;
            [self.PictureVw.image release];
            self.PictureVw.image = nil;
            self.image = [picA objectAtIndex:temp];
            [self.PictureVw setImage:[image getBestAvailImageForce]];
         
            [self performSelectorInBackground:@selector(_loadFullImage) withObject:nil];
            [self.tagTable reloadData];
            [self.btPref setEnabled:true];
            
        } else {
            [self.btNext setEnabled:false];
        }
}
- (IBAction)prevPic:(id)sender {
    if (image.idx==0) {
        return;
    }
  self.window.title = @"Loading better image..." ;
        long temp = image.idx - 1;
        NSLog(@"ID %li",temp);
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
            [self.PictureVw setImage:[image getBestAvailImageForce]];
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
 [self.PictureVw setImage:[image getSampleImage]];
        self.window.title = @"Loading better image..." ;
        [self performSelectorInBackground:@selector(_loadFullImage) withObject:nil];
        [self.tagTable setDelegate:self];
        [self.tagTable setDataSource:self];
           [self.PictureVw setAnimates:TRUE];
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
    [self.image browse];
}
- (IBAction)downloadThis:(id)sender {
    [self.image performDownload];
}

- (IBAction)copyToboard:(id)sender {
    [self.image copyToPasteBoard];
}



@end
