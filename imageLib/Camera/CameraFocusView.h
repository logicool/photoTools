//
//  CameraFocusView.h
//  imageLib
//
//  Created by 高函 on 17/2/9.
//  Copyright © 2017年 高函. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraFocusView;

@protocol CameraFocusDelegate <NSObject>

@optional
-(void) cameraFocusOptionsWithPoint:(CGPoint)point;

@end

@interface CameraFocusView : UIView

@property (nonatomic, weak)   id <CameraFocusDelegate> delegate;
@property (strong, nonatomic) UIImageView *focus;
@property (strong, nonatomic) NSTimer *timer;

@end
