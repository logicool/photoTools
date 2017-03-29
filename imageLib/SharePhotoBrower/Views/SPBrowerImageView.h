//
//  SPBrowerImageView.h
//  imageLib
//
//  Created by 高函 on 2017/3/16.
//  Copyright © 2017年 高函. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPBrowerImageView : UIImageView

/**
 *  是否有蒙版层
 */
@property (nonatomic , assign , getter=isMaskViewFlag) BOOL maskViewFlag;
/**
 *  蒙版层的颜色,默认白色
 */
@property (nonatomic , strong) UIColor *maskViewColor;
/**
 *  蒙版的透明度,默认 0.5
 */
@property (nonatomic , assign) CGFloat maskViewAlpha;
/**
 *  是否有右上角打钩的按钮
 */
@property (nonatomic , assign) BOOL animationRightTick;

@end
