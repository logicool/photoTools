//
//  CameraConfirmView.m
//  imageLib
//
//  Created by 高函 on 17/2/9.
//  Copyright © 2017年 高函. All rights reserved.
//

#import "CameraConfirmView.h"

static CGFloat BOTTOM_HEIGHT = 60;
static CGFloat TOP_HEIGHT = 44;

@implementation CameraConfirmView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self makeDownViewUI];
    }
    return self;
}

-(void) makeDownViewUI {
    // 显示照片的view 在imageForConfirm的set方法中设置frame和image
    UIImageView *photoDisplayView = [[UIImageView alloc] init];
    [self addSubview:photoDisplayView];
    self.imageForConfirm = photoDisplayView;
    
    CGFloat x = (self.frame.size.width) / 3;
    
    // 底部View
    UIView *controlView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - BOTTOM_HEIGHT, self.frame.size.width, BOTTOM_HEIGHT)];
    controlView.backgroundColor = [UIColor clearColor];
    controlView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self addSubview:controlView];
    
    //‘重拍’按钮
    UIButton *cancalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancalBtn.frame = CGRectMake(0, 0, x, BOTTOM_HEIGHT);
    [cancalBtn setTitle:@"重拍" forState:UIControlStateNormal];
    [cancalBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:cancalBtn];
    
    //‘编辑’按钮
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.frame = CGRectMake(x, 0, x, BOTTOM_HEIGHT);
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:editBtn];
    
    //‘保存照片’按钮
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(self.frame.size.width - x, 0, x, BOTTOM_HEIGHT);
    [doneBtn setTitle:@"保存" forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:doneBtn];
}


- (void)imageForConfirm:(UIImage *) image {
    if (image == nil) {
        return;
    }
    
//    CGSize size;
//    size.width = [UIScreen mainScreen].bounds.size.width;
//    size.height = ([UIScreen mainScreen].bounds.size.width / image.size.width) * image.size.height;
//    NSLog(@"%@",NSStringFromCGSize(size));
//    CGFloat x = (self.frame.size.width - size.width) / 2;
//    CGFloat y = (self.frame.size.height - size.height) / 2;
//    self.imageForConfirm.frame = CGRectMake(x, y, size.width, size.height);
    
    CGFloat viewWidth = self.frame.size.width;
    CGFloat viewHeigh = self.frame.size.width * 0.75;
    CGFloat drawStartY = CGRectGetMidY(self.frame) - (viewHeigh * 0.5) - TOP_HEIGHT;
    
    self.imageForConfirm.frame = CGRectMake(0, drawStartY, viewWidth, viewHeigh);
    
    [self.imageForConfirm setImage:image];
}

- (void)cancelAction {
    if ([_delegate respondsToSelector:@selector(cameraConfirmViewCancelBtnTouched)]) {
        [_delegate cameraConfirmViewCancelBtnTouched];
    }
    [self removeFromSuperview];
}

- (void)doneAction {
    if ([_delegate respondsToSelector:@selector(cameraConfirmViewSendBtnTouched)]) {
        [_delegate cameraConfirmViewSendBtnTouched];
    }
}

- (void)editAction {
    if ([_delegate respondsToSelector:@selector(cameraConfirmViewEditBtnTouched)]) {
        [_delegate cameraConfirmViewEditBtnTouched];
    }
}

@end
