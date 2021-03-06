//
//  CameraConfirmView.h
//  imageLib
//
//  Created by 高函 on 17/2/9.
//  Copyright © 2017年 高函. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraConfirmViewDelegate <NSObject>
- (void)cameraConfirmViewSendBtnTouched;
- (void)cameraConfirmViewCancelBtnTouched;
- (void)cameraConfirmViewEditBtnTouched;
@end

@interface CameraConfirmView : UIView
@property (nonatomic, weak) id <CameraConfirmViewDelegate> delegate;
@property (nonatomic) UIImageView * imageForConfirm;

- (void)imageForConfirm:(UIImage *) image;
@end
