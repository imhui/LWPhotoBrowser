//
//  LWZoomingView.m
//  LWPhotoBrowser
//
//  Created by LiYonghui on 14-6-16.
//  Copyright (c) 2014年 LW. All rights reserved.
//

#import "LWZoomingView.h"
#import "MBProgressHUD.h"
#import "LWPhoto.h"
#import "LWPhotoBrowser.h"

@interface LWZoomingView () <UIScrollViewDelegate> {
    
    UIImageView *_imageView;
    UITapGestureRecognizer *_singleTap;
    UITapGestureRecognizer *_doubleTap;
    
    MBProgressHUD *_progressHUD;
    LWPhotoBrowser *_photoBrowser;
    
}

@property (nonatomic, strong) UIImage *image;

@end

@implementation LWZoomingView

+ (LWZoomingView *)zoomViewWithPhoto:(LWPhoto *)photo {
    return [[self alloc] initWithPhoto:photo];
}

- (instancetype)initWithPhotoBrowser:(LWPhotoBrowser *)photoBrowser
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        _photoBrowser = photoBrowser;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithPhoto:(LWPhoto *)photo
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.photo = photo;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        self.delegate = self;
        self.bouncesZoom = YES;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 3.0;
        
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		_imageView.backgroundColor = [UIColor clearColor];
        _imageView.userInteractionEnabled = YES;
		[self addSubview:_imageView];
        
        
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapOnZoomView:)];
        _doubleTap.numberOfTapsRequired = 2;
        
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnZoomView:)];
        _singleTap.numberOfTapsRequired = 1;
        
        [_singleTap requireGestureRecognizerToFail:_doubleTap];
        
        [self addGestureRecognizer:_singleTap];
        [_imageView addGestureRecognizer:_doubleTap];
        
        
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
    return self;
}

- (void)setFrame:(CGRect)frame {
    
    BOOL needRelayoutImageView = NO;
    if ((CGRectGetWidth(frame) != CGRectGetWidth(self.frame)) || (CGRectGetHeight(frame) != CGRectGetHeight(self.frame))) {
        needRelayoutImageView = YES;
    }
    
    [super setFrame:frame];
    
    if (needRelayoutImageView) {
        [self layoutImageView];
    }
    
}

- (CGRect)imageViewLayoutFrame {
    
    if (!self.image) {
        return CGRectMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), 0, 0);
    }
    
    CGRect imageFrame = CGRectZero;
    CGSize imageSize = self.image.size;
    
    if (CGRectGetWidth(self.bounds) < CGRectGetHeight(self.bounds)) {
        CGFloat scale = imageSize.width / CGRectGetWidth(self.bounds);
        imageSize = CGSizeMake(CGRectGetWidth(self.bounds), ceilf(imageSize.height / scale));
        
        imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        if (imageSize.height <= CGRectGetHeight(self.bounds)) {
            imageFrame.origin.y = (CGRectGetHeight(self.bounds) - imageSize.height) / 2.0;
        }
    }
    else {
        CGFloat scale = imageSize.height / CGRectGetHeight(self.bounds);
        imageSize = CGSizeMake(ceilf(imageSize.width / scale), CGRectGetHeight(self.bounds));
        
        imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        imageFrame.origin.x = (CGRectGetWidth(self.bounds) - imageSize.width) / 2.0;
    }
    
    
    return imageFrame;
}

- (void)layoutImageView {
    self.zoomScale = self.minimumZoomScale;
    _imageView.frame = [self imageViewLayoutFrame];
    self.contentSize = _imageView.frame.size;
}

#pragma mark - Notification
- (void)photoDownloadProgressChanged:(NSNotification *)o {
    if ([o object] != self.photo) {
        return;
    }
    
    CGFloat progress = [[[o userInfo] objectForKey:@"progress"] floatValue];
    _progressHUD.progress = progress;
}

- (void)photoDownloadFinish:(NSNotification *)o {
    if ([o object] != self.photo) {
        return;
    }
    
    self.image = self.photo.displayImage;
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
- (void)setPhoto:(LWPhoto *)photo {
    
    self.zoomScale = self.minimumZoomScale;
    
    _photo = photo;
    
    if (_photo != nil) {
        if (_photo.displayImage == nil) {
            [self addSubview:_progressHUD];
            _progressHUD.progress = 0;
            [_progressHUD show:YES];
        }
    }
    else {
        [_progressHUD hide:YES];
    }

    self.image = self.photo.displayImage;
}

- (void)setImage:(UIImage *)image {
    
    _image = image;
    
    _imageView.image = _image;
    CGRect imageFrame = [self imageViewLayoutFrame];
    _imageView.frame = imageFrame;
    
}


#pragma mark - Tap Action
- (void)singleTapOnZoomView:(UITapGestureRecognizer *)singleTap {
    if (singleTap.state == UIGestureRecognizerStateEnded) {
        [_photoBrowser triggerControls];
    }
}

- (void)doubleTapOnZoomView:(UITapGestureRecognizer *)doubleTap {
    
    if (doubleTap.state == UIGestureRecognizerStateEnded) {
        
        if (self.zoomScale > self.minimumZoomScale) {
            [self setZoomScale:self.minimumZoomScale animated:YES];
        }
        else {
            
            CGPoint center = [doubleTap locationInView:_imageView];
            CGRect rect = [self zoomRectForScale:self.maximumZoomScale withCenter:center];
            [self zoomToRect:rect animated:YES];
            
        }
        
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect = CGRectZero;
    zoomRect.size.height = self.bounds.size.height / scale;
    zoomRect.size.width  = self.bounds.size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat offsetX = (CGRectGetWidth(scrollView.bounds) > scrollView.contentSize.width) ? (CGRectGetWidth(scrollView.bounds) - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height) ? (CGRectGetHeight(scrollView.bounds) - scrollView.contentSize.height) * 0.5 : 0.0;
    
    UIView *zoomView = [self viewForZoomingInScrollView:scrollView];
    zoomView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    
}

@end
