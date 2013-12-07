//
//  LWCaptionView.m
//  LWPhotoBrowser
//
//  Created by LiYonghui on 13-12-6.
//  Copyright (c) 2013年 LW. All rights reserved.
//

#import "LWCaptionView.h"

@interface LWCaptionView() {
    UILabel *_captionLabel;
}

@end

@implementation LWCaptionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        _captionLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 5, 5)];
        _captionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _captionLabel.backgroundColor = [UIColor clearColor];
        _captionLabel.font = [UIFont systemFontOfSize:12];
        _captionLabel.textColor = [UIColor whiteColor];
        _captionLabel.backgroundColor = [UIColor clearColor];
        _captionLabel.numberOfLines = 0;
        [self addSubview:_captionLabel];
        
    }
    return self;
}

- (void)setCaption:(NSString *)caption {
    _captionLabel.text = caption;
    [_captionLabel sizeToFit];
}

- (NSString *)caption {
    return _captionLabel.text;
}


@end
