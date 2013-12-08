LWPhotoBrowser
==============

An iOS photo Browser
--------------------


LWPhotoBrowser looks like the photo browser of the native Photos app in iOS. It can display one or more images from web URLs, file paths or UIImage Objects. It supports photos zooming and panning. Works on iOS 5+.



![screenshot1](https://github.com/imhui/LWPhotoBrowser/blob/master/screenshots/1.png)
![screenshot2](https://github.com/imhui/LWPhotoBrowser/blob/master/screenshots/2.png)

#### init LWPhoto
```
+ (LWPhoto *)photoWithImage:(UIImage *)image;
+ (LWPhoto *)photoWithFilePath:(NSString *)filePath;
+ (LWPhoto *)photoWithURL:(NSURL *)remoteURL;
````

#### init LWPhotoBrowser
```
LWPhotoBrowser *browser = [[LWPhotoBrowser alloc] initWithPhotos:photos];
```


