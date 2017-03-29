//
//  SPBrowerImageView.m
//  imageLib
//
//  Created by 高函 on 2017/3/16.
//  Copyright © 2017年 高函. All rights reserved.
//

#import "SPBrowerImageView.h"
#import "CommonHeader.h"

@interface SPBrowerImageView ()

@property (nonatomic, weak) UIView      *maskView;
@property (nonatomic, weak) UIImageView *tickImageView;
@property (nonatomic, weak) UIImageView *videoView;

@end

@implementation SPBrowerImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
    }
    return self;
}

- (UIView *)maskView {
    if (!_maskView) {
        UIView *maskView = [[UIView alloc] init];
        maskView.frame = self.bounds;
        maskView.backgroundColor = [UIColor whiteColor];
        maskView.alpha = 0.5;
        [self addSubview:maskView];
        self.maskView = maskView;
    }
    return _maskView;
}

- (UIImageView *)tickImageView {
    if (!_tickImageView) {
        UIImageView *tickImageView = [[UIImageView alloc] init];
        tickImageView.frame = CGRectMake(self.bounds.size.width - 28, 5, 21, 21);
        tickImageView.image = GetImage(@"checkbox_pic_non.png");
        [self addSubview:tickImageView];
        self.tickImageView = tickImageView;
    }
    return _tickImageView;
}

- (void)setMaskViewFlag:(BOOL)maskViewFlag {
    _maskViewFlag = maskViewFlag;
    
    if (!maskViewFlag) {
        // hidden
        [self.tickImageView setImage:GetImage(@"checkbox_pic_non.png")];
    }else{
        [self.tickImageView setImage:GetImage(@"checkbox_pic.png")];
    }
    self.animationRightTick = maskViewFlag;
}

- (void)setMaskViewColor:(UIColor *)maskViewColor {
    _maskViewColor = maskViewColor;
    self.maskView.backgroundColor = maskViewColor;
}

- (void)setMaskViewAlpha:(CGFloat)maskViewAlpha {
    _maskViewAlpha = maskViewAlpha;
    self.maskView.alpha = maskViewAlpha;
}

- (void)setAnimationRightTick:(BOOL)animationRightTick {
    _animationRightTick = animationRightTick;
}

@end
