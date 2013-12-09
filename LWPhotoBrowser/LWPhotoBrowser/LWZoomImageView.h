//
//  LWZoomImageView.h
//  LWPhotoBrowser
//
//  Created by LiYonghui on 13-12-6.
//  Copyright (c) 2013年 LW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LWPhoto;
@class LWPhotoBrowser;

@interface LWZoomImageView : UIScrollView

@property (nonatomic, strong) LWPhoto *photo;
           
+ (LWZoomImageView *)zoomViewWithPhoto:(LWPhoto *)photo;
- (void)zoomFromPoint:(CGPoint)point;
- (void)reset;

@end
