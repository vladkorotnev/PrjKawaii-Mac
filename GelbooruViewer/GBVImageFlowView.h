//
//  GBVImageFlowView.h
//  GelbooruViewer
//
//  Created by Vladislav Korotnev on 1/18/13.
//  Copyright (c) 2013 Vladislav Korotnev. All rights reserved.
//

#import "IKImageFlowView.h"
@protocol GBVImageFlowViewDelegate;
@interface GBVImageFlowView : IKImageFlowView
{
    id<GBVImageFlowViewDelegate> delegate;
}
@property (assign) id<GBVImageFlowViewDelegate>delegate;

@end

@protocol GBVImageFlowViewDelegate <NSObject>
@required
- (void)handleActivationOnIndex:(NSInteger)index;

@end
