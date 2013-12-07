//
//  LWZoomImageView.m
//  LWPhotoBrowser
//
//  Created by LiYonghui on 13-12-6.
//  Copyright (c) 2013年 LW. All rights reserved.
//

#import "LWZoomImageView.h"
#import "LWPhotoImageView.h"
#import "LWPhotoBrowser.h"
#import "LWPhoto.h"
#import "MBProgressHUD.h"

@interface LWZoomImageView () <UIScrollViewDelegate> {
    
    LWPhotoImageView *_imageView;
    MBProgressHUD *_progressHUD;
}

@end

@implementation LWZoomImageView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


+ (LWZoomImageView *)zoomViewWithPhoto:(LWPhoto *)photo {
    return [[self alloc] initWithPhoto:photo];
}

- (id)initWithPhoto:(LWPhoto *)photo
{
    self = [super init];
    if (self) {
        
        [self initialize];
        self.photo = photo;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    
    self.contentSize = self.frame.size;
    self.delegate = self;
    self.minimumZoomScale = 1.0;
    self.maximumZoomScale = 10.0;
    self.zoomScale = 1;
    
    _imageView = [[LWPhotoImageView alloc] initWithFrame:self.bounds];
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_imageView];
    
    _progressHUD = [[MBProgressHUD alloc] initWithView:self];
    _progressHUD.mode = MBProgressHUDModeAnnularDeterminate;
    _progressHUD.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoDownloadProgressChanged:)
                                                 name:LWPHOTO_DOWNLOAD_PROGRESS_CHANGED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoDownloadFinish:)
                                                 name:LWPHOTO_DOWNLOAD_FINISH_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoDownloadFail:)
                                                 name:LWPHOTO_DOWNLOAD_FAIL_NOTIFICATION object:nil];
    
}


- (void)setPhoto:(LWPhoto *)photo {
    _photo = photo;
    _imageView.image = _photo.displayImage;
    if (_imageView.image == nil) {
        [self addSubview:_progressHUD];
        [_progressHUD show:YES];
    }
}


- (void)photoDownloadProgressChanged:(NSNotification *)o {
    if ([o object] != self.photo) {
        return;
    }
    
    CGFloat progress = [[[o userInfo] objectForKey:@"progress"] floatValue];
    NSLog(@"progress: %f", progress);
    _progressHUD.progress = progress;
}

- (void)photoDownloadFinish:(NSNotification *)o {
    if ([o object] != self.photo) {
        return;
    }

    _imageView.image = self.photo.displayImage;
    [_progressHUD hide:YES afterDelay:0.5];
}

- (void)photoDownloadFail:(NSNotification *)o {
    if ([o object] != self.photo) {
        return;
    }
    
    NSDictionary *userinfo = [o userInfo];
    NSLog(@"photo download fail: %@", [userinfo objectForKey:@"error"]);
    _progressHUD.mode = MBProgressHUDModeText;
    _progressHUD.labelText = NSLocalizedString(@"Error", nil);
    
}

#pragma mark
- (void)zoomFromPoint:(CGPoint)point {
    
    if (self.zoomScale > 1.0) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
    else {
        
        NSLog(@"point: %@", NSStringFromCGPoint(point));
        CGPoint center = [_imageView convertPoint:point fromView:self];
        NSLog(@"center: %@", NSStringFromCGPoint(center));
        CGRect zoomRect = [self zoomRectForScale:self.maximumZoomScale withCenter:center];
        [self zoomToRect:zoomRect animated:YES];
    }
    
}


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = self.bounds.size.height / scale;
    zoomRect.size.width  = self.bounds.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}



@end
