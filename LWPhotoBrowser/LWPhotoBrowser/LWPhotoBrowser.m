//
//  LWPhotoBrowser.m
//  LWPhotoGallery
//
//  Created by LiYonghui on 13-12-6.
//  Copyright (c) 2013年 LW. All rights reserved.
//

#import "LWPhotoBrowser.h"
#import "MBProgressHUD.h"
#import "LWPhotoImageView.h"
#import "LWPhoto.h"
#import "LWZoomImageView.h"
#import "LWCaptionView.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "LWZoomingView.h"


@interface LWPhotoBrowser () <UIScrollViewDelegate, UIActionSheetDelegate> {
    UIScrollView *_pagingScrollView;
    LWCaptionView *_captionView;
    BOOL _shouldHideStatusBar;
    
    LWZoomingView *_leftImageView;
    LWZoomingView *_centerImageView;
    LWZoomingView *_rightImageView;
    CGPoint _lastContentOffset;
    
    UIBarStyle _lastBarStyle;
    UIStatusBarStyle _lastStatusBarStyle;
    
    NSInteger _currentIndex;
    
    
}

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation LWPhotoBrowser


- (id)initWithPhotos:(NSArray *)photos
{
    self = [self init];
    if (self) {
        self.photos = photos;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        self.wantsFullScreenLayout = YES;
        self.hidesBottomBarWhenPushed = YES;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    
    _lastBarStyle = self.navigationController.navigationBar.barStyle;
    _lastStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    
    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    self.toolbarItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(toolbarActionButtonItemAction:)]];

    self.view.backgroundColor = [UIColor blackColor];
    _pagingScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.delegate = self;
    _pagingScrollView.backgroundColor = [UIColor blackColor];
    _pagingScrollView.minimumZoomScale = 1.0;
    _pagingScrollView.maximumZoomScale = 2.0;
    [self.view addSubview:_pagingScrollView];
    
    _captionView = [[LWCaptionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.navigationController.toolbar.bounds) - 80, CGRectGetWidth(self.view.bounds), 80)];
    _captionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_captionView];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    singleTapGesture.numberOfTapsRequired = 1;
    [_pagingScrollView addGestureRecognizer:singleTapGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [_pagingScrollView addGestureRecognizer:doubleTapGesture];
    
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    
    _leftImageView = [[LWZoomingView alloc] init];
    _centerImageView = [[LWZoomingView alloc] init];
    _rightImageView = [[LWZoomingView alloc] init];
    
    _leftImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _centerImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _rightImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self layoutPhotos];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:_lastStatusBarStyle animated:YES];
    self.navigationController.navigationBar.barStyle = _lastBarStyle;
    [self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark - Gesture Action
- (void)singleTapAction:(UITapGestureRecognizer *)gestureRecognizer {

    if (self.navigationController.navigationBarHidden) {
        [self showToolbar];
    }
    else {
        [self hideToolbar];
    }
    
}

- (void)doubleTapAction:(UITapGestureRecognizer *)gestureRecognizer {
    
    LWZoomingView *zoomView = [self visibleImageView];
    CGPoint point = [gestureRecognizer locationInView:zoomView];
    [zoomView zoomFromPoint:point];
    
}

- (void)toolbarActionButtonItemAction:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Copy", nil), NSLocalizedString(@"Save", nil), nil];
    [sheet showInView:self.navigationController.view];
    
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self copyPhoto];
    }
    else if (buttonIndex == 1) {
        [self savePhoto];
    }
    
}


- (void)copyPhoto {
    LWPhoto *photo = [self visiblePhoto];
    if (photo.displayImage != nil) {
        
        self.progressHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.progressHUD.mode = MBProgressHUDModeIndeterminate;
        self.progressHUD.labelText = [NSString stringWithFormat:@"%@\u2026" , NSLocalizedString(@"Copying", nil)];
        [self.progressHUD showAnimated:YES
                   whileExecutingBlock:^{
                       
                       [[UIPasteboard generalPasteboard] setData:UIImagePNGRepresentation(photo.displayImage)
                                               forPasteboardType:@"LWPhoto.png"];
                       
                       self.progressHUD.mode = MBProgressHUDModeText;
                       self.progressHUD.labelText = NSLocalizedString(@"Copied", nil);
                       sleep(1);
                   } onQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
                       completionBlock:^{
                           self.progressHUD = nil;
                       }];
        
        
    }
}


- (void)savePhoto {
    
    LWPhoto *photo = [self visiblePhoto];
    if (photo.displayImage != nil) {
        
        self.progressHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.progressHUD.mode = MBProgressHUDModeIndeterminate;
        self.progressHUD.labelText = [NSString stringWithFormat:@"%@\u2026" , NSLocalizedString(@"Saving", nil)];
        [self.progressHUD showAnimated:YES
                   whileExecutingBlock:^{
                       UIImageWriteToSavedPhotosAlbum(photo.displayImage, self,
                                                      @selector(image:didFinishSavingWithError:contextInfo:), nil);
                       sleep(1);
                   } onQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
                       completionBlock:^{
                           self.progressHUD = nil;
                       }];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    self.progressHUD.mode = MBProgressHUDModeText;
    self.progressHUD.labelText = error == nil ? NSLocalizedString(@"Saved", nil) : NSLocalizedString(@"Failed", nil);
    
}

#pragma mark
- (void)updateTitle {
    
    NSInteger index = [self visiblePhotoIndex];
    self.title = [NSString stringWithFormat:@"%d / %d", index + 1, self.photos.count];
    [self updateCaptionView];
}

- (void)updateCaptionView {
    LWPhoto *photo = [self visiblePhoto];
    _captionView.caption = photo.caption;
    _captionView.hidden = _captionView.caption == nil || _captionView.caption.length == 0;
}

- (NSInteger)visiblePhotoIndex {
    _currentIndex = _pagingScrollView.contentOffset.x / CGRectGetWidth(_pagingScrollView.bounds);
    return _currentIndex;
}


- (LWZoomingView *)visibleImageView {
    
    LWZoomingView *imageView = _centerImageView;
    if (self.photos.count <= 3) {
        NSInteger index = [self visiblePhotoIndex];
        switch (index) {
            case 0:
                imageView = _centerImageView;
                break;
            case 1:
                imageView = _rightImageView;
                break;
            case 2:
                imageView = _leftImageView;
            default:
                break;
        }
        
    }

    return imageView;
}

- (LWPhoto *)visiblePhoto {
    NSInteger index = [self visiblePhotoIndex];
    return self.photos[index];
}

- (LWPhoto *)photoWithContentOffset:(CGPoint)contentOffset {
    
    if (contentOffset.x < 0) {
        return nil;
    }
    
    NSInteger index = contentOffset.x / CGRectGetWidth(_pagingScrollView.bounds);
    return index < self.photos.count ? self.photos[index] : nil;
    
}


- (void)layoutPhotos {
    
    _pagingScrollView.frame = self.view.bounds;
    _pagingScrollView.contentSize = CGSizeMake(self.photos.count * CGRectGetWidth(_pagingScrollView.bounds), 0);
    
    for (NSInteger i = 0; i < self.photos.count && i < 3; i++) {
        LWPhoto *photo = self.photos[i];
        LWZoomingView *imageView = nil;
        switch (i) {
            case 0:
                imageView = _centerImageView;
                break;
            case 1:
                imageView = _rightImageView;
                break;
            case 2:
                imageView = _leftImageView;
            default:
                break;
        }
        
        imageView.photo = photo;
        imageView.frame = CGRectMake(CGRectGetWidth(_pagingScrollView.bounds) * i, 0, CGRectGetWidth(_pagingScrollView.bounds), CGRectGetHeight(_pagingScrollView.bounds));
        [_pagingScrollView addSubview:imageView];
    }
    
    [self updateTitle];
}


- (void)resetInvisibleImageViewZooomScale {
    
    LWZoomingView *visibleView = [self visibleImageView];
    if (visibleView == _leftImageView) {
        [_centerImageView setZoomScale:_centerImageView.minimumZoomScale animated:YES];
        [_rightImageView setZoomScale:_rightImageView.minimumZoomScale animated:YES];
    }
    else if (visibleView == _centerImageView) {
        [_leftImageView setZoomScale:_leftImageView.minimumZoomScale animated:YES];
        [_rightImageView setZoomScale:_rightImageView.minimumZoomScale animated:YES];
    }
    else {
        [_leftImageView setZoomScale:_leftImageView.minimumZoomScale animated:YES];
        [_centerImageView setZoomScale:_centerImageView.minimumZoomScale animated:YES];
    }
    
}


/**
 *  adjust LWZoomingView position for reuse
 */
- (void)adjustPagingViewPosition {
    
    NSInteger pageWidth = CGRectGetWidth(_pagingScrollView.bounds);
    NSInteger xOffset = _pagingScrollView.contentOffset.x;
    CGFloat direction = xOffset - _lastContentOffset.x;
    
    if (xOffset == _centerImageView.frame.origin.x) {
        return;
    }
    
    if (self.photos.count <= 3) {
        // photos's count less than 3, no need to adjust the page's position
        [self resetInvisibleImageViewZooomScale];
        return;
    }
    
    
    if (direction > 0) {
        
        if (xOffset >= CGRectGetMaxX(_centerImageView.frame)) {
            
            [_centerImageView setZoomScale:_centerImageView.minimumZoomScale animated:YES];
            
            CGRect rect = _leftImageView.frame;
            rect.origin.x = CGRectGetMaxX(_rightImageView.frame);
            _leftImageView.frame = rect;
            
            LWZoomingView *tmpView = _centerImageView;
            _centerImageView = _rightImageView;
            _rightImageView = _leftImageView;
            _leftImageView = tmpView;
            
            _rightImageView.photo = [self photoWithContentOffset:CGPointMake(CGRectGetMinX(_rightImageView.frame), 0)];
            
        }
        
    }
    else if (direction < 0) {
        
        if (xOffset <= CGRectGetMinX(_centerImageView.frame)) {
            
            [_centerImageView setZoomScale:_centerImageView.minimumZoomScale animated:YES];
            
            CGRect rect = _rightImageView.frame;
            rect.origin.x = CGRectGetMinX(_leftImageView.frame) - pageWidth;
            _rightImageView.frame = rect;
            
            
            LWZoomingView *tmpView = _centerImageView;
            _centerImageView = _leftImageView;
            _leftImageView = _rightImageView;
            _rightImageView = tmpView;
            
            _leftImageView.photo = [self photoWithContentOffset:CGPointMake(CGRectGetMinX(_leftImageView.frame), 0)];

        }
        
    }
    
    _lastContentOffset = _pagingScrollView.contentOffset;
    
}



#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_centerImageView.zoomScale > _centerImageView.minimumZoomScale) {
        return;
    }
    
    if (self.photos.count <= 3) {
        return;
    }
    
    [self adjustPagingViewPosition];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self adjustPagingViewPosition];
    [self updateTitle];
}


#pragma mark - Rotation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [self performSelector:@selector(pagingViewRotateToOrientation) withObject:nil afterDelay:0];
    
}


- (void)pagingViewRotateToOrientation {
    
    _pagingScrollView.frame = self.view.bounds;
    
    CGRect leftRect = _leftImageView.frame;
    CGRect centerRect = _centerImageView.frame;
    CGRect rightRect = _rightImageView.frame;
    
    centerRect.size = _pagingScrollView.bounds.size;
    leftRect.size = centerRect.size;
    rightRect.size = centerRect.size;
    
    centerRect.origin.x = CGRectGetWidth(_pagingScrollView.bounds) * _currentIndex;
    leftRect.origin.x = CGRectGetMinX(centerRect) - CGRectGetWidth(centerRect);
    rightRect.origin.x = CGRectGetMaxX(centerRect);
    
    _centerImageView.frame = centerRect;
    _leftImageView.frame = leftRect;
    _rightImageView.frame = rightRect;
    
    _pagingScrollView.contentSize = CGSizeMake(self.photos.count * CGRectGetWidth(_pagingScrollView.bounds), 0);
    [_pagingScrollView setContentOffset:CGPointMake(CGRectGetMinX(centerRect), 0) animated:NO];
    
    _captionView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.navigationController.toolbar.bounds) - 80, CGRectGetWidth(self.view.bounds), 80);
}


#pragma mark - Appearance
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (BOOL)prefersStatusBarHidden {
    return _shouldHideStatusBar;
}


#pragma mark - Toolbar
- (void)showToolbar {
    
    _shouldHideStatusBar = NO;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         _captionView.alpha = 1.0;
                         [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                         if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                             [self setNeedsStatusBarAppearanceUpdate];
                         }
                         [self.navigationController setNavigationBarHidden:NO animated:YES];
                         [self.navigationController setToolbarHidden:NO animated:YES];
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)hideToolbar {
    
    _shouldHideStatusBar = YES;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _captionView.alpha = 0.0;
                         [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                         if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                             [self setNeedsStatusBarAppearanceUpdate];
                         }
                         [self.navigationController setNavigationBarHidden:YES animated:YES];
                         [self.navigationController setToolbarHidden:YES animated:YES];
                     } completion:^(BOOL finished) {
                     }];
}




@end
