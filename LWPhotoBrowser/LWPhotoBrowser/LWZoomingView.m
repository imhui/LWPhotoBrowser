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
    
    UIImageView *_zoomView;
    CGSize _imageSize;
    CGPoint _pointToCenterAfterResize;
    CGFloat _scaleToRestoreAfterResize;
    
    MBProgressHUD *_progressHUD;
    LWPhotoBrowser *_photoBrowser;
}

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
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        self.enableSingleTap = YES;
        
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _zoomView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    _zoomView.frame = frameToCenter;
}

- (void)setFrame:(CGRect)frame
{
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
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
    
    [self displayImage:_photo.displayImage];
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
- (void)singleTapOnZoomView:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [_photoBrowser triggerControls];
    }
}

- (void)doubleTapOnZoomView:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [sender locationInView:self];
        [self zoomFromPoint:point];
    }
}

#pragma mark
- (void)setPhoto:(LWPhoto *)photo {
    
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
    [self displayImage:_photo.displayImage];
}



- (void)displayImage:(UIImage *)image
{
    // clear the previous image
    [_zoomView removeFromSuperview];
    _zoomView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    // make a new UIImageView for the new image
    _zoomView = [[UIImageView alloc] initWithImage:image];
    _zoomView.userInteractionEnabled = YES;
    [self addSubview:_zoomView];
    
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapOnZoomView:)];
    doubleTap.numberOfTapsRequired = 2;
    [_zoomView addGestureRecognizer:doubleTap];
    
    if (self.enableSingleTap) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnZoomView:)];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [self addGestureRecognizer:singleTap];
    }
    
    [self configureForImageSize:image.size];
}

- (void)zoomFromPoint:(CGPoint)point {
    
    if (self.zoomScale > self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
    else {
        CGPoint center = [self convertPoint:point toView:_zoomView];
        CGRect zoomRect = [self zoomRectForScale:self.maximumZoomScale withCenter:center];
        [self zoomToRect:zoomRect animated:YES];
    }
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


- (void)configureForImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width  / _imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / _imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
    BOOL imagePortrait = _imageSize.height > _imageSize.width;
    BOOL phonePortrait = boundsSize.height > boundsSize.width;
    CGFloat minScale = imagePortrait == phonePortrait ? xScale : MIN(xScale, yScale);
    
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
//    maxScale = 1.0;
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
}


#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

#pragma mark - Rotation support

- (void)prepareToResize
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:_zoomView];
    
    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing
{
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:_zoomView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomView;
}


@end
