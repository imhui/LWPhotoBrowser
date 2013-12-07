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
#import <QuartzCore/QuartzCore.h>


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)



@interface LWPhotoBrowser () <UIScrollViewDelegate> {
    UIScrollView *_pagingScrollView;
    LWCaptionView *_captionView;
    BOOL _shouldHideStatusBar;
    
    NSMutableArray *_zoomViews;
}

@end

@implementation LWPhotoBrowser


- (id)init
{
    self = [super init];
    if (self) {
        
        if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        self.wantsFullScreenLayout = YES;
        self.hidesBottomBarWhenPushed = YES;
        
        _zoomViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    
    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];

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
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self layoutImages];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.toolbar.barStyle = UIBarStyleDefault;
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)layoutImages {
    
    for (NSInteger i = 0; i < self.photos.count; i++) {
        
        LWPhoto *photo = self.photos[i];
        LWZoomImageView *imageView = [LWZoomImageView zoomViewWithPhoto:photo];
        imageView.frame = CGRectMake(CGRectGetWidth(_pagingScrollView.bounds) * i, 0, CGRectGetWidth(_pagingScrollView.bounds), CGRectGetHeight(_pagingScrollView.bounds));
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_pagingScrollView addSubview:imageView];
        [_zoomViews addObject:imageView];
    }
    
    [self updateCaptionView];
    
    _pagingScrollView.contentSize = CGSizeMake(self.photos.count * CGRectGetWidth(_pagingScrollView.bounds), 0);
    
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
    
    LWZoomImageView *zoomView = [self visibleZoomView];
    CGPoint point = [gestureRecognizer locationInView:zoomView];
    [zoomView zoomFromPoint:point];
    
}

#pragma mark
- (void)updateTitle {
    NSInteger index = [self visiblePhotoIndex];
    self.title = [NSString stringWithFormat:@"%d / %d", index + 1, self.photos.count];
}

- (void)updateCaptionView {
    LWPhoto *photo = [self visiblePhoto];
    _captionView.caption = photo.caption;
}

- (NSInteger)visiblePhotoIndex {
    return _pagingScrollView.contentOffset.x / CGRectGetWidth(_pagingScrollView.bounds);
}


- (LWZoomImageView *)visibleZoomView {
    NSInteger index = [self visiblePhotoIndex];
    return _zoomViews[index];
}

- (LWPhoto *)visiblePhoto {
    NSInteger index = [self visiblePhotoIndex];
    return self.photos[index];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateCaptionView];
    [self updateTitle];
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
    _captionView.hidden = NO;
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
                         _captionView.hidden = YES;
                     }];
}


@end
