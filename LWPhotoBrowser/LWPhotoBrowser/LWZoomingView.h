//
//  LWZoomingView.h
//  LWPhotoBrowser
//
//  Created by LiYonghui on 14-6-16.
//  Copyright (c) 2014年 LW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LWPhoto;
@class LWPhotoBrowser;
@interface LWZoomingView : UIScrollView

@property (nonatomic, strong) LWPhoto *photo;

+ (LWZoomingView *)zoomViewWithPhoto:(LWPhoto *)photo;
- (instancetype)initWithPhotoBrowser:(LWPhotoBrowser *)photoBrowser;

@end
