//
//  LWPhoto.h
//  LWPhotoGallery
//
//  Created by LiYonghui on 13-12-6.
//  Copyright (c) 2013年 LW. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString * const LWPHOTO_DOWNLOAD_PROGRESS_CHANGED_NOTIFICATION = @"LWPHOTO_DOWNLOAD_PROGRESS_CHANGED_NOTIFICATION";
static NSString * const LWPHOTO_DOWNLOAD_FINISH_NOTIFICATION = @"LWPHOTO_DOWNLOAD_FINISH_NOTIFICATION";
static NSString * const LWPHOTO_DOWNLOAD_FAIL_NOTIFICATION = @"LWPHOTO_DOWNLOAD_FAIL_NOTIFICATION";

@interface LWPhoto : NSObject

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UIImage *placeholder;
@property (nonatomic, readonly) UIImage *displayImage;


+ (LWPhoto *)photoWithImage:(UIImage *)image;
+ (LWPhoto *)photoWithFilePath:(NSString *)filePath;
+ (LWPhoto *)photoWithURL:(NSURL *)remoteURL;

@end
