//
//  SPAlbums.h
//  imageLib
//
//  Created by 高函 on 2017/3/17.
//  Copyright © 2017年 高函. All rights reserved.
//

#import <UIKit/UIKit.h>
// 回调
typedef void(^groupCallBackBlock)(id obj);

@interface SPAlbums : NSObject

/**
 *  获取所有组
 */
+ (instancetype) defaultPicker;

/**
 *  传入一个AssetsURL来获取UIImage
 */
- (void) getAssetsPhotoWithURLs:(NSURL *) url callBack:(groupCallBackBlock ) callBack;


@end
