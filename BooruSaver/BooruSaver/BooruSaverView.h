//
//  BooruSaverView.h
//  BooruSaver
//
//  Created by Vladislav Korotnev on 1/22/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "GBVImage.h"
#import "GBVSaverConfigWindowController.h"
#import <QuartzCore/QuartzCore.h>
#import "STOverlayController.h"
@interface BooruSaverView : ScreenSaverView<NSXMLParserDelegate,GBVImageDownloadDelegate> {
    NSString*board;
    NSString*tags;
    int curPage;
    int curPic;
    int interval;
    int preventAbsurd;
    int totalPosts;
    int randomized;
    bool previewing;
    NSMutableArray*pictures;
    bool preloadIsBackground;
    NSImageView   *currentImageView;
    NSTextField *label;
    NSMutableArray* alreadyShownPics;
   
}



@end
