//
//  LWPhotoImageView.m
//  LWPhotoBrowser
//
//  Created by LiYonghui on 13-12-6.
//  Copyright (c) 2013年 LW. All rights reserved.
//

#import "LWPhotoImageView.h"
#import "LWPhoto.h"

@interface LWPhotoImageView () {
    UIImageView *_imageView;
}

@end

@implementation LWPhotoImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
    }
    return self;
}


- (void)setImage:(UIImage *)image {
    _imageView.image = image;
}

- (UIImage *)image {
    return _imageView.image;
}


@end
