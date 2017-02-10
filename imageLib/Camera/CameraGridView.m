//
//  CameraGridView.m
//  imageLib
//
//  Created by 高函 on 17/2/9.
//  Copyright © 2017年 高函. All rights reserved.
//

#import "CameraGridView.h"
#define lineWidth (1 / [UIScreen mainScreen].scale)
#define lineOffset lineWidth/2

@implementation CameraGridView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.viewWidth = frame.size.width;
        self.viewHeigh = frame.size.width * 0.75;
        self.drawStartY = CGRectGetMidY(frame) - (self.viewHeigh * 0.5) - frame.origin.y;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawLine:context withColor:[UIColor colorWithWhite:0.65 alpha:0.07] byWidth:5];
    CGContextSaveGState(context);
    [self drawLine:context withColor:[UIColor colorWithWhite:1.0 alpha:0.45] byWidth:lineWidth];
}

/**
 * 绘制十字网格
 */
-(void) drawLine: (CGContextRef) context withColor: (UIColor *) color byWidth: (CGFloat) width {
    
    CGFloat width1 =  [self CGFloatPixelRound:self.viewWidth/3];
    CGFloat width2 =  [self CGFloatPixelRound:self.viewWidth/3 * 2];
    CGFloat height1 =  [self CGFloatPixelRound:self.viewHeigh/3];
    CGFloat height2 =  [self CGFloatPixelRound:self.viewHeigh/3 * 2];
    
    // H line 0
    CGContextSetStrokeColorWithColor( context, color.CGColor);
    CGContextMoveToPoint(context, 0, self.drawStartY + lineOffset);
    CGContextAddLineToPoint(context, self.viewWidth, self.drawStartY +lineOffset);
    CGContextSetLineWidth(context, width);
    CGContextStrokePath(context);
    
    CGContextSaveGState(context);
    
    // H line 1
    CGContextSetStrokeColorWithColor( context, color.CGColor);
    CGContextMoveToPoint(context, 0, self.drawStartY + height1 + lineOffset);
    CGContextAddLineToPoint(context, self.viewWidth, self.drawStartY + height1 + lineOffset);
    CGContextSetLineWidth(context, width);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    
    // H line 2
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, 0, self.drawStartY + height2 + lineOffset);
    CGContextAddLineToPoint(context, self.viewWidth, self.drawStartY + height2 + lineOffset);
    CGContextSetLineWidth(context, width);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    
    // H line 3
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, 0, self.drawStartY + self.viewHeigh - lineOffset);
    CGContextAddLineToPoint(context, self.viewWidth, self.drawStartY + self.viewHeigh - lineOffset);
    CGContextSetLineWidth(context, width);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    
    // V line 0
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, lineOffset, self.drawStartY);
    CGContextAddLineToPoint(context, lineOffset, self.drawStartY + self.viewHeigh);
    CGContextSetLineWidth(context, width);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    
    
    // V line 1
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, width1 + lineOffset, self.drawStartY);
    CGContextAddLineToPoint(context, width1 + lineOffset, self.drawStartY + self.viewHeigh);
    CGContextSetLineWidth(context, width);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    
    // V line 2
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, width2 + lineOffset, self.drawStartY);
    CGContextAddLineToPoint(context, width2 + lineOffset, self.drawStartY + self.viewHeigh);
    CGContextSetLineWidth(context, width);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    
    // V line 3
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, self.viewWidth - lineOffset, self.drawStartY);
    CGContextAddLineToPoint(context, self.viewWidth - lineOffset, self.drawStartY + self.viewHeigh);
    CGContextSetLineWidth(context, width);
    CGContextStrokePath(context);
}


-(CGFloat) CGFloatPixelRound: (CGFloat) value {
    CGFloat scale = [[UIScreen mainScreen] scale];
    return round(value * scale) / scale;
}


@end
