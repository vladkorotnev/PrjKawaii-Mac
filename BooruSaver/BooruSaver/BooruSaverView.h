//
//  BooruSaverView.h
//  BooruSaver
//
//  Created by Vladislav Korotnev on 1/22/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

@interface BooruSaverView : ScreenSaverView<NSXMLParserDelegate> {
    NSString*board;
    NSString*tags;
    int curPage;
    int curPic;
    int interval;
    int preventAbsurd;
    NSMutableArray*pictures;
    NSImageView   *currentImageView;

}



@end
