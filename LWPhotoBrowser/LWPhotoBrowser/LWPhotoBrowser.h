//
//  LWPhotoBrowser.h
//  LWPhotoGallery
//
//  Created by LiYonghui on 13-12-6.
//  Copyright (c) 2013年 LW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWPhotoBrowser : UIViewController

@property (nonatomic, strong) NSArray *photos;

- (id)initWithPhotos:(NSArray *)photos;
- (void)triggerControls;

@end
