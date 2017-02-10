//
//  CameraFocusView.m
//  imageLib
//
//  Created by 高函 on 17/2/9.
//  Copyright © 2017年 高函. All rights reserved.
//

//定义UIImage对象
#define IMAGE(A) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:A ofType:nil]]


#import "CameraFocusView.h"

@implementation CameraFocusView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _focus = [[UIImageView alloc]init];
        _focus.image = IMAGE(@"cameraFocus.png");
    }
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
    _focus.frame = CGRectMake(0, 0, 80, 80);
    _focus.center = point;
    [self addSubview:_focus];
    
    [self shakeToShow:_focus];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(hideFocusView) userInfo:nil repeats:YES];
    if ([self.delegate respondsToSelector:@selector(cameraFocusOptionsWithPoint:)]) {
        [self.delegate cameraFocusOptionsWithPoint:point];
    }
}

- (void) shakeToShow:(UIView*)aView{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [aView.layer addAnimation:animation forKey:nil];
}

-(void) hideFocusView
{
    [_focus removeFromSuperview];
    [_timer invalidate];
}

@end
