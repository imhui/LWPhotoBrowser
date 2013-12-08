LWPhotoBrowser
==============

An iOS photo Browser
--------------------


LWPhotoBrowser looks like the photo browser of the native Photos app in iOS. It can display one or more images from web URLs, file paths or UIImage Objects. It supports photos zooming and panning. Works on iOS 5+.


<img src="https://raw.github.com/imhui/LWPhotoBrowser/master/screenshots/1.png" alt="Drawing" style="width: 200px;"/>
<img src="https://raw.github.com/imhui/LWPhotoBrowser/master/screenshots/2.png" alt="Drawing" style="width: 200px;"/>

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


