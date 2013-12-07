//
//  LWPhoto.m
//  LWPhotoGallery
//
//  Created by LiYonghui on 13-12-6.
//  Copyright (c) 2013年 LW. All rights reserved.
//

#import "LWPhoto.h"
#import <CommonCrypto/CommonDigest.h>

@interface NSString (MKNetworkKitAdditions)

- (NSString *) md5;
@end


@implementation NSString (MKNetworkKitAdditions)

- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int) strlen(cStr), result);
    return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}
@end

@interface LWPhoto () <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    NSURLConnection *_connection;
    long long _imageTotalLength;
    NSMutableData *_receivedData;
}

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic, strong) NSString *photoPath;

@end

@implementation LWPhoto


+ (LWPhoto *)photoWithImage:(UIImage *)image {
    return [[self alloc] initWithImage:image];
}


+ (LWPhoto *)photoWithFilePath:(NSString *)filePath {
    return [[self alloc] initWithFilePath:filePath];
}


+ (LWPhoto *)photoWithURL:(NSURL *)remoteURL {
    return [[self alloc] initWithURL:remoteURL];
}


- (id)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (id)initWithFilePath:(NSString *)filePath
{
    self = [super init];
    if (self) {
        self.photoPath = filePath;
    }
    return self;
}


- (id)initWithURL:(NSURL *)remoteURL
{
    self = [super init];
    if (self) {
        self.photoURL = remoteURL;
    }
    return self;
}

- (UIImage *)displayImage {
    
    UIImage *image = nil;
    
    if (self.image != nil) {
        image = image;
    }
    else if (self.photoPath != nil && [[NSFileManager defaultManager] fileExistsAtPath:self.photoPath]) {
        image = [UIImage imageWithContentsOfFile:self.photoPath];
    }
    else if (self.photoURL != nil) {
        
        NSString *localPath = [self getPhotoLocalPath:[self uniqueIdentifier]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
            image = [UIImage imageWithContentsOfFile:localPath];
        }
        else {
            [self startDownload];
        }
    }
    
    return image;
}

#pragma mark
- (void)startDownload {
    
    if (_connection != nil) {
        return;
    }
    
    _receivedData = [[NSMutableData alloc] initWithCapacity:0];
    _imageTotalLength = 0;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.photoURL];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
}

#pragma mark - 
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _imageTotalLength = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
    [self handleDownloadProgress];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self handleDownloadFinished];
    _connection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self handleDownloadFailWithError:error];
    _connection = nil;
}


- (void)handleDownloadProgress {
    
    CGFloat progress = _receivedData.length / (double)_imageTotalLength;
    [[NSNotificationCenter defaultCenter] postNotificationName:LWPHOTO_DOWNLOAD_PROGRESS_CHANGED_NOTIFICATION
                                                        object:self
                                                      userInfo:@{@"photo": self, @"progress": @(progress)}];
}

- (void)handleDownloadFinished {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [_receivedData writeToFile:[self getPhotoLocalPath:[self uniqueIdentifier]] atomically:YES];
        _receivedData = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:LWPHOTO_DOWNLOAD_FINISH_NOTIFICATION
                                                                object:self userInfo:nil];
        });
    });
    
}

- (void)handleDownloadFailWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:LWPHOTO_DOWNLOAD_FAIL_NOTIFICATION
                                                        object:self
                                                      userInfo:@{@"error": error}];
    _receivedData = nil;
    
}


#pragma mark
- (NSString *)uniqueIdentifier {
    NSMutableString *str = [NSMutableString stringWithFormat:@"GET %@", self.photoURL.absoluteString];
    return [str md5];
}


- (NSString *)applicationCachesDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


- (NSString *)getPhotoLocalPath:(NSString *)photoUrl {
    NSString *path = [[self applicationCachesDirectory] stringByAppendingPathComponent:@"LWPhoto"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [path stringByAppendingPathComponent:photoUrl];
}














@end
