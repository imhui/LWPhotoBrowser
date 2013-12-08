//
//  LWCaptionView.m
//  LWPhotoBrowser
//
//  Created by LiYonghui on 13-12-6.
//  Copyright (c) 2013年 LW. All rights reserved.
//

#import "LWCaptionView.h"

@interface LWCaptionView() {
    UIScrollView *_contentView;
    UILabel *_captionLabel;
}

@end

@implementation LWCaptionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
        
        _captionLabel = [[UILabel alloc] initWithFrame:CGRectInset(_contentView.bounds, 4, 4)];
        _captionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _captionLabel.backgroundColor = [UIColor clearColor];
        _captionLabel.font = [UIFont systemFontOfSize:12];
        _captionLabel.textColor = [UIColor whiteColor];
        _captionLabel.backgroundColor = [UIColor clearColor];
        _captionLabel.numberOfLines = 0;
        [_contentView addSubview:_captionLabel];
        
    }
    return self;
}

- (void)setCaption:(NSString *)caption {
    _captionLabel.text = caption;
    
    CGFloat width = CGRectGetWidth(_contentView.bounds) - 10;
    CGSize size = [caption sizeWithFont:_captionLabel.font
                      constrainedToSize:CGSizeMake(width, INT_MAX)
                          lineBreakMode:UILineBreakModeTailTruncation];
    _captionLabel.frame = CGRectMake(5, 5, width, size.height);
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.bounds), CGRectGetHeight(_captionLabel.bounds) + 10);
}

- (NSString *)caption {
    return _captionLabel.text;
}


@end
