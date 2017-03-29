//
//  SPBrowerCollectionViewCell.h
//  imageLib
//
//  Created by 高函 on 2017/3/16.
//  Copyright © 2017年 高函. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UICollectionView;

@interface SPBrowerCollectionViewCell : UICollectionViewCell
+ (instancetype) cellWithCollectionView : (UICollectionView *) collectionView cellForItemAtIndexPath:(NSIndexPath *) indexPath;

@property (nonatomic , strong) UIImage *cellImage;
@end
